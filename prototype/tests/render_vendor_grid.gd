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

func tile_center(grid, index: int = 0) -> Vector2:
	var rect = grid.pages[grid.page][index].rect
	return grid.global_position+(Vector2(rect.position)+Vector2(rect.size)/2)*grid.CELL

func run():
	var g = Game.new()
	g.run_seed = 170126
	root.add_child(g)
	g.sound_enabled = false
	g.begin()
	await create_timer(0.4).timeout
	await walk_to(g,"weapons")
	var m = g.hud.hub_menu
	check(m.get_global_rect().end.x <= 1280 and m.get_global_rect().end.y <= 674,"vendor grid panel fits")
	await pointer(tile_center(m.stock_list),false)
	await process_frame
	await process_frame
	check(m.chosen.is_empty() and m.card_host.get_child_count() == 2,"hover previews without selecting or buying")
	await capture("60-weapon-exchange")
	await click_at(tile_center(m.sell_list))
	var part = m.chosen
	var wallet = g.silicon
	var value = g.Economy.value(part)
	await click_at(m.sell_button.get_global_rect().get_center())
	check(g.silicon == wallet+value and g.Backpack.index_of(g.inventory,part) < 0,"grid selected sale transfers exact part")
	await click_at(m.stock_list.get_parent().get_child(0).get_global_rect().get_center())
	await click_at(tile_center(m.stock_list))
	check(m.source == "buyback" and is_same(m.chosen.item,part),"buyback grid preserves exact identity")
	await capture("61-buyback-grid")
	await click_at(m.buy_button.get_global_rect().get_center())
	check(g.silicon == wallet and g.Backpack.index_of(g.inventory,part) >= 0,"grid buyback reverses sale")
	g.close_contact()
	await create_timer(0.3).timeout
	await walk_to(g,"armor")
	await pointer(tile_center(m.stock_list),false)
	await capture("62-armor-exchange")
	check(m.stock_list.entries.size() == g.shops.armor.size(),"armor stock fully represented")
	await click_at(tile_center(m.stock_list))
	var bought = m.chosen
	await click_at(m.buy_button.get_global_rect().get_center())
	check(g.Backpack.index_of(g.inventory,bought) >= 0,"grid purchase reaches backpack")
	# Synthetic buyback history verifies presentation paging without changing production capacity.
	for i in range(35): g.buyback.append({"item":g.Loot.make_item("weapon",2,g.rng,false),"price":40})
	m.buybacks = true
	m.show_role("armor")
	await process_frame
	check(m.stock_list.pages.size() > 1,"long buyback has pages")
	var seen = {}
	for tiles in m.stock_list.pages:
		for tile in tiles:
			check(not seen.has(tile.index),"entry appears once")
			seen[tile.index] = true
	check(seen.size() == g.buyback.size(),"all buyback entries accessible")
	await click_at(m.stock_list.get_parent().get_child(2).get_child(2).get_global_rect().get_center())
	check(m.stock_list.page == 1,"next page button works")
	await capture("63-buyback-pages")
	print("VENDOR GRID GUI FAILURES: ",failures)
	g.queue_free()
	await process_frame
	quit(1 if failures else 0)
