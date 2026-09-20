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
	print("NAV FAILURE ",game.player.position," target=",game.target_contact," path=",game.path," paused=",game.paused)
	check(false,"walk/click timed out for "+role)

func run():
	var g = Game.new()
	g.run_seed = 170126
	root.add_child(g)
	g.sound_enabled = false
	g.begin()
	await create_timer(0.3).timeout
	await capture("50-clean-hud")
	g.hp = 30
	await click_at(g.hud.potion_buttons.life.get_global_rect().get_center())
	check(g.potions.life == 5 and g.hp > 30,"HUD life potion click")
	g.mana = 0
	await click_at(g.hud.potion_buttons.mana.get_global_rect().get_center())
	check(g.potions.mana == 3 and g.mana > 20,"HUD mana potion click")
	await click_at(g.hud.menu_buttons.character.get_global_rect().get_center())
	check(g.character_open,"character icon opens stats")
	await click_at(g.hud.menu_buttons.inventory.get_global_rect().get_center())
	check(g.inventory_open and not g.character_open,"inventory icon switches panel")
	g.toggle_inventory()
	await click_at(g.hud.menu_buttons.system.get_global_rect().get_center())
	check(g.menu_open == "system" and g.paused,"system icon opens paused menu")
	await capture("51-system-menu")
	g.close_contact()
	await walk_to(g,"debug")
	check(g.hud.hub_menu.get_global_rect().end.y <= 674,"expanded debug panel fits")
	var actions = g.hud.hub_menu.body.get_child(3)
	await click_at(actions.get_child(0).get_global_rect().get_center())
	check(g.potions.life == 99 and g.potions.mana == 99,"debug max potion button")
	actions = g.hud.hub_menu.body.get_child(3)
	await click_at(actions.get_child(1).get_global_rect().get_center())
	check(g.keycards.size() == 19,"debug unlock waypoint button")
	await capture("52-debug-supplies")
	actions = g.hud.hub_menu.body.get_child(3)
	await click_at(actions.get_child(2).get_global_rect().get_center())
	check(g.keycards.is_empty(),"debug reset waypoint button")
	g.close_contact()
	await create_timer(0.3).timeout
	await walk_to(g,"weapons")
	check(g.hud.hub_menu.get_global_rect().end.y <= 674,"vendor supplies fit panel")
	g.potions.life = 90
	var money = g.silicon
	await click_at(g.hud.hub_menu.body.get_child(2).get_child(0).get_global_rect().get_center())
	check(g.potions.life == 91 and g.silicon == money-8,"vendor potion purchase button")
	await capture("53-potion-vendor")
	g.close_contact()
	g.start_run()
	await create_timer(0.5).timeout
	await click_at(g.hud.menu_buttons.wormhole.get_global_rect().get_center())
	check(not g.wormhole.is_empty(),"B icon creates field wormhole")
	await capture("54-field-wormhole")
	await walk_to_portal(g)
	check(g.area == "hub","click wormhole returns to garage")
	await capture("55-town-wormhole")
	await click_at(g.hud.menu_buttons.wormhole.get_global_rect().get_center())
	check(g.area == "lobby","B icon returns to field origin")
	print("SUPPLY GUI FAILURES: ",failures)
	g.queue_free()
	await process_frame
	quit(1 if failures else 0)

func walk_to_portal(g):
	for entry in g.interactables:
		if entry.role == "wormhole":
			var pos = g.camera.unproject_position(entry.node.position+Vector3(0,0.8,0))*Vector2(root.get_visible_rect().size)/Vector2(g.viewport.size)
			await click_at(pos)
			for i in range(240):
				if g.area == "hub": return
				await physics_frame
			return
