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

func click_at(pos: Vector2):
	await pointer(pos,false)
	await mouse_button(pos,true)
	await mouse_button(pos,false)
	await process_frame

func walk_to(game, role: String):
	var contact: Dictionary = {}
	for entry in game.interactables:
		if entry.role == role: contact = entry
	if contact.is_empty(): check(false,"missing contact "+role); return
	var pos = game.camera.unproject_position(contact.node.position+Vector3(0,0.8,0))*Vector2(root.get_visible_rect().size)/Vector2(game.viewport.size)
	await click_at(pos)
	for i in range(600):
		if game.menu_open == role or (role == "gate" and game.area == "lobby"): return
		await physics_frame
	check(false,"walk/click timed out for "+role)

func run():
	var g = Game.new()
	g.run_seed = 170126
	root.add_child(g)
	g.sound_enabled = false
	g.begin()
	await create_timer(0.3).timeout
	await walk_to(g,"debug")
	var menu = g.hud.hub_menu
	await click_at(menu.body.get_child(menu.body.get_child_count()-2).get_global_rect().get_center())
	check(g.inventory.size() == 29,"debug kit button grants element and rarity samples")
	check(menu.get_global_rect().end.y <= 674,"debug panel still fits")
	g.close_contact()
	g.toggle_inventory()
	await process_frame
	var magenta
	for tile in g.hud.inventory_grid.get_children():
		if g.inventory[tile.index].get("tier",0) == 4: magenta = tile
	await pointer(magenta.get_global_rect().get_center(),false)
	await create_timer(0.4).timeout
	check(is_instance_valid(g.hud.hover_card),"magenta hover card renders")
	await capture("70-rarity-halos")
	g.toggle_character()
	var tabs = g.hud.character_tabs
	await process_frame
	var bar = tabs.get_tab_bar()
	await click_at(bar.global_position+bar.get_tab_rect(1).get_center())
	check(tabs.current_tab == 1,"Elements tab click")
	check(g.hud.character_panel.get_global_rect().end.y <= 674,"paged character sheet fits HUD")
	await capture("71-elements-page")
	await click_at(bar.global_position+bar.get_tab_rect(2).get_center())
	check(tabs.current_tab == 2,"Affinities tab click")
	await capture("72-affinities-page")
	g.toggle_character()
	g.start_run()
	# Test fixtures place all four kinds together for visual inspection.
	g.set_physics_process(false)
	g.player.position = Vector3(0,0,13)
	for kind in range(4): g.Chests.build(g,g.Chests.create(g,kind,Vector3(-5+kind*4,0,10),100+kind))
	await create_timer(0.8).timeout
	await capture("73-container-family")
	var chest = g.interactables[-1]
	g.player.position = chest.node.position+Vector3(0,0,1)
	var key = InputEventKey.new()
	key.physical_keycode = KEY_E
	key.pressed = true
	Input.parse_input_event(key)
	await process_frame
	check(chest.chest.opened and g.drops.size() == 2,"E opens superchest and drops equipment")
	await capture("74-superchest-open")
	print("REWARDS GUI FAILURES: ",failures)
	g.queue_free()
	await process_frame
	quit(1 if failures else 0)
