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

func run():
	var game = Game.new()
	game.run_seed = 170126
	root.add_child(game)
	game.restart(false,false,"run")
	game.sound_enabled = false
	game.begin()
	game.toggle_inventory()
	await create_timer(0.3).timeout
	await capture("16-salvage-inventory")
	var grid = game.hud.inventory_grid
	var blade = index_of(game,"weapon",1)
	var at = grid.global_position+Vector2(game.inventory[blade].grid_pos)*34+Vector2(17,17)
	var right = game.hud.equipment_slots.right.global_position+Vector2(48,40)
	await drag(at,right)
	check(is_same(game.equipment.right,game.inventory[blade]),"light drag to RIGHT equips")
	var heavy = index_of(game,"weapon",2)
	at = grid.global_position+Vector2(game.inventory[heavy].grid_pos)*34+Vector2(17,17)
	await drag(at,game.hud.equipment_slots.left.global_position+Vector2(48,40))
	check(is_same(game.equipment.left,game.inventory[heavy]) and is_same(game.equipment.right,game.inventory[heavy]),"heavy GUI drag reserves both slots")
	game.auto_pack()
	await process_frame
	at = grid.global_position+Vector2(game.inventory[blade].grid_pos)*34+Vector2(17,17)
	await drag(at,game.hud.equipment_slots.head.global_position+Vector2(48,40))
	check(not is_same(game.equipment.head,game.inventory[blade]),"weapon refused by head slot")
	await drag(at,right)
	check(is_same(game.equipment.right,game.inventory[blade]) and game.equipment.left.model == -1,"light replaces heavy and clears LEFT")
	game.auto_pack()
	await process_frame
	var pos = game.Backpack.first_fit(game.inventory,game.equipment,game.inventory[blade])
	await drag(right,grid.global_position+Vector2(pos)*34+Vector2(17,17))
	check(game.equipment.right.model == -1 and game.inventory[blade].grid_pos == pos,"GUI unequip into grid")
	await mouse_button(grid.global_position+Vector2(pos)*34+Vector2(17,17),true,MOUSE_BUTTON_RIGHT)
	await mouse_button(grid.global_position+Vector2(pos)*34+Vector2(17,17),false,MOUSE_BUTTON_RIGHT)
	check(game.Backpack.worn(game.inventory[blade],game.equipment),"right-click equips weapon")
	# Show color ladder on compact salvage examples.
	game.restart(false,false,"run")
	for tier in range(1,5):
		var item = game.Loot.make_item("neck",0,game.rng,true,8,tier)
		game.add_to_backpack(item)
	game.toggle_inventory()
	game.hud.selection = game.inventory.size()-2
	game.hud.refresh_inventory()
	await capture("17-salvage-rarities")
	check(game.hud.inventory_panel.get_global_rect().end.y <= 674,"inventory stays above resource HUD")
	var sample = game.Loot.make_item("weapon",3,game.rng,true,12,4)
	game.inventory[index_of(game,"weapon",3)] = sample
	game.auto_pack()
	game.hud.selection = index_of(game,"weapon",3)
	game.hud.refresh_inventory()
	await capture("17b-heavy-comparison")
	check(game.hud.inventory_panel.get_global_rect().end.y <= 674,"rare heavy selection stays compact without growing panel")
	game.toggle_inventory()
	game.paused = true
	game.camera.size = 13.5
	game.player.position = Vector3(-4,0,3)
	game.pet.rotation.y = 0.5
	game.equip_item(index_of(game,"weapon",2))
	for base in range(4):
		game.equip_item(index_of(game,"locomotion",base))
		game.pet.position.y = 0.25 if base == 3 else 0
		await create_timer(0.4).timeout
		await capture("18-locomotion-"+str(base))
	game.toggle_character()
	await capture("19-salvage-stats")
	print("SALVAGE GUI failures: ",failures)
	game.queue_free()
	await process_frame
	quit(1 if failures else 0)
