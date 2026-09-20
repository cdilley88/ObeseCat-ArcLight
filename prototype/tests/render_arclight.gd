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
	g.open_tower_map()
	await capture("110-arclight-act-map")
	g.close_contact()
	g.restart(false,true,"dining")
	g.restart(false,true,"hub")
	await create_timer(0.3).timeout
	await walk_to(g,"dispatch")
	await capture("111-dispatch-chefbot-quest")
	for child in g.hud.hub_menu.body.get_children():
		if child is Button and child.text == "ACCEPT QUEST": await click_at(child.get_global_rect().get_center())
	check(g.chef_quest == "active","Dispatch accept button activates ChefBot quest")
	g.close_contact()
	g.restart(false,true,"dining_3")
	g.set_physics_process(false)
	var chef = g.enemies.back()
	g.player.position = chef.node.position+Vector3(-3,0,4)
	await create_timer(0.4).timeout
	await capture("112-chefbot-floor12")
	g.hit_enemy(chef,100000)
	var hat = {}
	for drop in g.drops.duplicate():
		if drop.item.get("unique_id","") == "chefbot_hat":
			hat = drop.item
			g.player.position = drop.node.position
			g.pickup(drop)
	g.equip_item(g.Backpack.index_of(g.inventory,hat),"head")
	g.toggle_inventory()
	var card = preload("res://scripts/item_card.gd").new()
	g.hud.root.add_child(card)
	card.position = Vector2(120,150)
	card.setup(hat,true)
	await capture("113-chefbot-unique-hat")
	check(hat.tier == 5 and g.equipment.head == hat,"Unique hat equips and preview renders")
	card.queue_free()
	g.toggle_inventory()
	g.restart(false,true,"obesecat")
	g.player.position = g.enemies.back().node.position+Vector3(-4,0,5)
	await create_timer(0.4).timeout
	await capture("114-obesecat-showdown")
	print("ARCLIGHT GUI failures: ",failures)
	quit(1 if failures else 0)
