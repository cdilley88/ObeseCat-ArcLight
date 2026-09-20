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

func press_named(g, caption: String):
	for child in g.hud.hub_menu.body.find_children("*","Button",true,false):
		if child.text == caption:
			await click_at(child.get_global_rect().get_center())
			return
	check(false,"button missing: "+caption)
func run():
	var g = Game.new()
	g.run_seed = 170126
	root.add_child(g)
	g.sound_enabled = false
	g.begin()
	await create_timer(0.2).timeout
	await walk_to(g,"debug")
	await capture("100-world-seed-developer")
	await press_named(g,"RANDOMIZE")
	check(g.run_seed != 170126,"developer randomize button changes world seed")
	await walk_to(g,"debug")
	var field = g.hud.hub_menu.body.find_child("WorldSeed",true,false)
	field.value = 54321
	await press_named(g,"APPLY SEED")
	check(g.run_seed == 54321,"explicit seed button applies chosen value")
	await walk_to(g,"debug")
	await press_named(g,"ENTER DEBUG ARENA")
	await walk_to(g,"arena_control")
	await capture("101-world-seed-range")
	await press_named(g,"RANDOMIZE")
	check(g.area == "debug_arena" and g.run_seed != 54321 and g.chests.size() == 5,"arena randomize rebuilds chests in place")
	print("SEED GUI failures: ",failures)
	quit(1 if failures else 0)
