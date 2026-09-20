extends SceneTree
const Game = preload("res://scripts/main.gd")
var failures = 0

func _initialize(): call_deferred("run")

func capture(filename: String):
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../artifacts/" + filename + ".png")

func pointer(pos: Vector2, held: bool):
	root.warp_mouse(pos)
	var event = InputEventMouseMotion.new()
	event.position = pos
	event.global_position = pos
	event.relative = Vector2(12, 12)
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if held else 0
	Input.parse_input_event(event)
	await process_frame

func mouse_button(pos: Vector2, pressed: bool, button_index: int = MOUSE_BUTTON_LEFT):
	root.warp_mouse(pos)
	var event = InputEventMouseButton.new()
	event.position = pos
	event.global_position = pos
	event.button_index = button_index
	event.pressed = pressed
	Input.parse_input_event(event)
	await process_frame

func drag(from: Vector2, to: Vector2, shot: String = ""):
	await pointer(from, false)
	await mouse_button(from, true)
	await pointer(from + Vector2(13, 13), true)
	await pointer(to, true)
	if shot != "": await capture(shot)
	await mouse_button(to, false)
	await process_frame

func check(ok: bool, description: String):
	if not ok: failures += 1; push_error(description)
	print("GUI: ", description, " = ", ok)

func index_of(game, slot: String, model: int) -> int:
	for i in range(game.inventory.size()):
		if game.inventory[i].slot == slot and game.inventory[i].model == model: return i
	return -1

func hover_at(game, pos: Vector2):
	await pointer(pos,false)
	await create_timer(0.3).timeout
	await process_frame

func run():
	var game = Game.new()
	game.run_seed = 170126
	root.add_child(game)
	game.restart(false,false,"run")
	game.sound_enabled = false
	game.begin()
	game.toggle_inventory()
	await create_timer(0.4).timeout
	await capture("21-fitting-bay")
	check(game.hud.inventory_panel.get_global_rect().end.y <= 674,"preview inventory fits above resource HUD")
	var grid = game.hud.inventory_grid
	var helmet = index_of(game,"head",1)
	var at = grid.global_position+Vector2(game.inventory[helmet].grid_pos)*34+Vector2(17,17)
	await hover_at(game,at)
	check(is_instance_valid(game.hud.hover_card),"backpack hover opens illustrated card")
	check(game.hud.hover_card.get_global_rect().position.x >= 0 and game.hud.hover_card.get_global_rect().end.y <= 800,"hover card clamped inside screen")
	await capture("22-hover-helmet")
	await pointer(Vector2(40,150),false)
	await process_frame
	check(not is_instance_valid(game.hud.hover_card),"leaving item dismisses card")
	var revision: int = game.hud.character_preview.revision
	await drag(at,game.hud.equipment_slots.head.global_position+Vector2(48,40))
	check(game.hud.character_preview.revision > revision and game.equipment.head.model == 1,"GUI swap updates live preview")
	await hover_at(game,game.hud.equipment_slots.head.global_position+Vector2(48,40))
	check(is_instance_valid(game.hud.hover_card),"worn equipment has hover card")
	await capture("23-worn-card-preview")
	game.toggle_inventory()
	await process_frame
	check(not is_instance_valid(game.hud.hover_card),"closing inventory clears card")
	game.toggle_inventory()
	var rare = game.Loot.make_item("weapon",3,game.rng,true,12,4)
	game.inventory[index_of(game,"weapon",3)] = rare
	game.auto_pack()
	await process_frame
	at = grid.global_position+Vector2(rare.grid_pos)*34+Vector2(17,17)
	await hover_at(game,at)
	check(is_instance_valid(game.hud.hover_card),"rare heavy card opens")
	await capture("24-rare-card")
	check(game.hud.hover_card.size.y < 650,"long rare card stays compact")
	await mouse_button(at,true)
	await pointer(at+Vector2(13,13),true)
	await pointer(at+Vector2(50,30),true)
	check(not is_instance_valid(game.hud.hover_card),"dragging suppresses hover card")
	await mouse_button(Vector2(30,150),false)
	game.equip_item(index_of(game,"weapon",2))
	game.equip_item(index_of(game,"locomotion",2))
	game.hud.refresh_inventory()
	await pointer(Vector2(40,150),false)
	await create_timer(0.2).timeout
	await capture("25-preview-spider-heavy")
	var before: float = game.hud.character_preview.model.rotation.y
	# Use the actual rotation button.
	var right_column = game.hud.character_preview.get_parent()
	right_column.get_child(0).get_child(2).pressed.emit()
	check(game.hud.character_preview.model.rotation.y != before,"preview rotation control")
	game.equip_item(index_of(game,"locomotion",3))
	game.hud.refresh_inventory()
	await create_timer(0.2).timeout
	await capture("26-preview-hover")
	print("HOVER/PREVIEW GUI failures: ",failures)
	game.queue_free()
	await process_frame
	quit(1 if failures else 0)
