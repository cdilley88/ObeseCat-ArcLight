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
	var game = Game.new()
	game.run_seed = 170126
	root.add_child(game)
	game.sound_enabled = false
	game.begin()
	await create_timer(0.5).timeout
	await capture("41-garage-refuge")
	await walk_to(game,"elevator")
	check(game.menu_open == "elevator","garage elevator opens through click navigation")
	await process_frame
	var menu = game.hud.hub_menu
	check(menu.get_global_rect().end.y <= 674,"tower route panel fits HUD")
	await capture("42-tower-map-locked")
	game.close_contact()
	await walk_to(game,"gate")
	check(game.area == "lobby","garage stairs clicked to enter Lobby")
	await create_timer(0.4).timeout
	game.paused = true
	await capture("43-lobby-arrival")
	# Composition tour uses test-only travel/positioning, not a balance claim.
	for id in game.Tower.ZONES:
		game.restart(false,true,id)
		game.paused = true
		game.player.position = Vector3(-5,0,3)
		await create_timer(0.7).timeout
		await capture("zone-"+id)
	# Explicit test-only kills unlock route; click real elevator Travel UI.
	game.restart(false,true,"lobby")
	for enemy in game.enemies: game.hit_enemy(enemy,99999)
	game.player.position = game.Tower.spawn("lobby")
	game.paused = false
	await create_timer(0.5).timeout
	await walk_to(game,"elevator")
	check(game.menu_open == "elevator","floor elevator opens by click")
	await capture("44-elevator-lobby-unlocked")
	var grid = menu.body.get_child(4)
	var travel = grid.get_child(2)
	check(travel is Button and not travel.disabled,"garage destination enabled")
	await click_at(travel.get_global_rect().get_center())
	check(game.area == "hub","elevator Travel button returns to garage")
	print("TOWER GUI FAILURES: ",failures)
	game.queue_free()
	await process_frame
	quit(1 if failures else 0)
