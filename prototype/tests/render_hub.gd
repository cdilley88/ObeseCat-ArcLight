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
	await create_timer(0.4).timeout
	await capture("27-town-plaza")
	await walk_to(game,"weapons")
	check(game.menu_open == "weapons","click NPC routes and opens weapons stall")
	var menu = game.hud.hub_menu
	check(menu.get_global_rect().end.x <= 1280 and menu.get_global_rect().end.y <= 674,"vendor panel within HUD bounds")
	await click_at(menu.sell_list.global_position+(Vector2(menu.sell_list.pages[0][0].rect.position)+Vector2(menu.sell_list.pages[0][0].rect.size)/2)*28)
	check(menu.source == "bag","mouse selects sellable backpack item")
	var item = menu.chosen
	var money: int = game.silicon
	await capture("28-vendor-selling")
	await click_at(menu.sell_button.get_global_rect().get_center())
	check(game.silicon > money and game.Backpack.index_of(game.inventory,item) < 0,"sell button transfers selected item")
	await click_at(menu.stock_list.get_parent().get_child(0).get_global_rect().get_center())
	check(menu.buybacks,"buyback tab opens")
	await click_at(menu.stock_list.global_position+(Vector2(menu.stock_list.pages[0][0].rect.position)+Vector2(menu.stock_list.pages[0][0].rect.size)/2)*28)
	await click_at(menu.buy_button.get_global_rect().get_center())
	check(game.silicon == money and game.Backpack.index_of(game.inventory,item) >= 0,"GUI buyback restores exact item")
	game.close_contact()
	await walk_to(game,"debug")
	check(game.menu_open == "debug","debug contact opens through navigation")
	menu.debug_fields.level.value = 5
	menu.debug_fields.silicon.value = 750
	menu.debug_fields.strength.value = 25
	await capture("29-debug-operator")
	await click_at(menu.body.get_child(menu.body.get_child_count()-1).get_global_rect().get_center())
	check(game.progression.level == 5 and game.silicon == 750 and game.progression.attributes.strength == 25,"debug Apply button sets values")
	game.close_contact()
	await walk_to(game,"armor")
	await click_at(menu.stock_list.global_position+(Vector2(menu.stock_list.pages[0][0].rect.position)+Vector2(menu.stock_list.pages[0][0].rect.size)/2)*28)
	var purchased = menu.chosen
	await click_at(menu.buy_button.get_global_rect().get_center())
	check(game.Backpack.index_of(game.inventory,purchased) >= 0 and game.silicon < 750,"armor vendor GUI purchase")
	game.close_contact()
	for role in ["cosmetics","broker","dispatch"]:
		await walk_to(game,role)
		check(game.menu_open == role,"future-role contact reachable: "+role)
		game.close_contact()
	await walk_to(game,"gate")
	check(game.area == "lobby" and game.run_number == 1 and game.progression.level == 5,"walking through gate preserves debug build")
	await capture("30-town-to-run")
	game.hp = 0
	var key = InputEventKey.new()
	key.physical_keycode = KEY_T
	key.pressed = true
	Input.parse_input_event(key)
	await process_frame
	check(game.area == "hub" and game.hp > 0,"T after defeat returns to town")
	await capture("31-return-to-town")
	print("HUB GUI failures: ",failures)
	game.queue_free()
	await process_frame
	quit(1 if failures else 0)
