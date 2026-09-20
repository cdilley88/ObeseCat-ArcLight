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
	await capture("80-debug-arena-entry")
	for child in g.hud.hub_menu.body.find_children("*","Button",true,false):
		if child is Button and child.text == "ENTER DEBUG ARENA":
			await click_at(child.get_global_rect().get_center())
	check(g.area == "debug_arena","debug button enters arena")
	await create_timer(0.3).timeout
	await capture("81-five-chest-range")
	await walk_to(g,"arena_control")
	await capture("82-range-operator")
	for child in g.hud.hub_menu.body.find_children("*","Button",true,false):
		if child is Button and child.text == "SPAWN STATIONARY":
			await click_at(child.get_global_rect().get_center())
	check(g.enemies.size() == 1,"operator spawns stationary target")
	g.set_physics_process(false)
	g.player.position = Vector3(0,0,2)
	g.enemies[0].node.position = Vector3(0,0,-2)
	g.launch_missile(g.enemies[0].node.position,50,{"type":"heat","splash":2.1})
	for i in range(15): g.update_effects(0.025)
	await capture("83-missile-trail")
	for i in range(30): g.update_effects(0.025)
	g.player.position = Vector3.ZERO
	g.enemies[0].node.position = Vector3(0,0,-2)
	var cleaver = g.Loot.make_item("weapon",4,g.rng,false)
	g.equipment.left = cleaver
	g.equipment.right = cleaver
	g.Models.equip(g.pet,g.equipment)
	g.request_attack(g.enemies[0])
	g.resolve_attack()
	await create_timer(0.12).timeout
	await capture("84-phase-cleaver-swing")
	check(abs(g.pet.get_node("Gear/WeaponLeft").rotation.y) > 0.1,"equipped cleaver animates on attack")
	print("ARENA GUI failures: ",failures)
	quit(1 if failures else 0)
