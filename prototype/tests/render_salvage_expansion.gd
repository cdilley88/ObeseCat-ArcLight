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
	g.restart(false,true,"debug_arena")
	await create_timer(0.2).timeout
	await walk_to(g,"arena_control")
	var count = g.inventory.size()+g.drops.size()
	for child in g.hud.hub_menu.body.get_children():
		if child is Button and child.text == "GIVE CYBERNETIC BASE SAMPLES": await click_at(child.get_global_rect().get_center())
	check(g.inventory.size()+g.drops.size() == count+19,"base sampler delivers all nineteen wearable bases")
	g.close_contact()
	g.restart(false,true,"debug_arena")
	g.set_physics_process(false)
	g.inventory.clear()
	for slot in g.Loot.SLOTS: g.equipment[slot] = g.Loot.empty_item(slot)
	for kind in ["head","neck","barding","locomotion"]:
		for model in range(g.Loot.BASES[kind].size()):
			var item = g.Loot.make_item(kind,model,g.rng,false)
			g.inventory.append(item)
	for item in g.inventory:
		if (item.slot == "head" and item.model == 2) or (item.slot == "barding" and item.model == 3) or (item.slot == "locomotion" and item.model == 2) or (item.slot == "neck" and item.model == 3): g.equipment[item.slot] = item
	g.Backpack.arrange(g.inventory,g.equipment)
	g.hp = g.current_stats().max_life
	g.mana = g.current_stats().max_mana
	g.Models.equip(g.pet,g.equipment)
	g.toggle_inventory()
	await create_timer(0.3).timeout
	await capture("90-new-cybernetic-inventory")
	check(g.hud.inventory_panel.visible,"new bases render in inventory")
	g.toggle_inventory()
	g.hud.hide()
	for child in g.dynamic.get_children(): child.visible = false
	for i in range(6):
		var model = g.Models.pet()
		g.dynamic.add_child(model)
		model.position = Vector3(-5+(i%3)*5,0,-3+int(i/3)*6)
		var gear = {}
		for slot in g.Loot.SLOTS: gear[slot] = g.Loot.empty_item(slot)
		gear.barding = g.Loot.make_item("barding",i,g.rng,false)
		if i == 0: gear.head = g.Loot.make_item("head",2,g.rng,false)
		g.Models.equip(model,gear)
		model.rotation.y = -0.4
		model.scale = Vector3.ONE*1.6
		var label = g.Models.text3d(model,gear.barding.name,Vector3(0,2,0),Color.WHITE,24)
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.pixel_size = 0.012
	await capture("91-barding-model-gallery")
	g.hud.show()
	g.equipment.neck["item_discovery"] = 45
	g.equipment.neck["silicon_discovery"] = 30
	g.equipment.neck["mana_regen"] = 1.2
	g.equipment.neck["guard_cybernetic"] = 12
	g.equipment.neck["melee_arc"] = 18
	g.toggle_character()
	g.hud.character_tabs.current_tab = 3
	await capture("92-modifier-sheet")
	check(g.hud.character_tabs.get_tab_count() == 4,"modifier page available")
	print("SALVAGE GUI failures: ",failures)
	quit(1 if failures else 0)
