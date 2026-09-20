extends PanelContainer
const Loot = preload("res://scripts/loot.gd")
const Card = preload("res://scripts/item_card.gd")
var game
var body: VBoxContainer
var stock_list
var sell_list
var stock_items: Array = []
var sell_items: Array = []
var chosen: Dictionary = {}
var source = ""
var buybacks = false
var card_host: VBoxContainer
var buy_button: Button
var sell_button: Button
var debug_fields: Dictionary = {}

func setup(owner_game):
	game = owner_game
	position = Vector2(128,110)
	custom_minimum_size = Vector2(1024,530)
	var style = StyleBoxFlat.new()
	style.bg_color = Color("101d25fc")
	style.border_color = Color("6d9690")
	style.set_border_width_all(2)
	style.set_content_margin_all(16)
	add_theme_stylebox_override("panel",style)
	hide()

func clear():
	for child in get_children():
		remove_child(child)
		child.queue_free()
	body = VBoxContainer.new()
	body.add_theme_constant_override("separation",10)
	add_child(body)
	chosen = {}
	source = ""

func text(value: String, size: int = 15) -> Label:
	return game.hud.label(value,size)

func button(value: String, action: Callable) -> Button:
	return game.hud.button(value,action)

func open(role: String):
	buybacks = false
	show_role(role)

func show_role(role: String):
	clear()
	show()
	var header = HBoxContainer.new()
	body.add_child(header)
	var title = text(("RANGE OPERATOR" if role == "arena_control" else role.to_upper())+" / %d SILICON" % game.silicon,22)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	header.add_child(button("CLOSE [ESC]",func(): game.close_contact()))
	if role in ["weapons","armor"]: vendor(role)
	elif role == "debug": debugger()
	elif role == "dispatch": dispatch_quest()
	elif role == "arena_control": arena_controls()
	elif role == "system": system_menu()
	elif role == "reset_confirm":
		body.add_child(text("Reset character, inventory, currency and tower? This cannot be undone.",18))
		body.add_child(button("RESET EVERYTHING",func(): game.restart(false)))
		body.add_child(button("RESET WITH NEW SEED",func(): game.restart(true)))
		body.add_child(button("CANCEL",func(): game.menu_open = "system"; show_role("system")))
	elif role in ["tower","elevator"]: tower_map(role)
	else:
		var words = {
			"dispatch":"DISPATCH / ACT I / ASCENT\n\nThe refuge is in basement parking. Your objective is the CEO office.\nTake the Lobby stairs. Floor supervisors carry elevator keycards.\nHigher floors have stronger security and better parts, permanently.\nSide doors lead to optional annexes. Press V for the tower route.\n\nGarage elevators can start a NEW SORTIE to repopulate encounters.\nThis keeps your character and keycards, but clears tower-floor loot.\nNo named quest chains or next act are implemented yet.",
			"broker":"SIGNAL BROKER / Reserved role\n\nGambling and special-currency exchanges are planned for later.\nNo wagers, alternate tokens, or purchases are enabled here yet.",
			"cosmetics":"IDENTITY / STYLE / Reserved role\n\nA future home for cosmetic gear and appearance options.\nYour current look still comes directly from equipped parts.\nNo cosmetic purchases are enabled here yet."}
		body.add_child(text(words.get(role,"Contact offline."),18))
		body.add_child(button("BACK TO GARAGE",func(): game.close_contact()))

func vendor(role: String):
	body.add_child(text("Buy parts or sell backpack salvage. Unequip worn gear before selling. Buyback costs exactly what you received.",13))
	var supplies = HBoxContainer.new()
	body.add_child(supplies)
	for kind in ["life","mana"]:
		supplies.add_child(button("BUY "+kind.to_upper()+" POTION / 8 Si (%d/99)" % game.potions[kind],func(): game.buy_potion(kind); show_role(role)))
	var columns = HBoxContainer.new()
	columns.add_theme_constant_override("separation",12)
	body.add_child(columns)
	var left = VBoxContainer.new()
	columns.add_child(left)
	left.add_child(button("BUYBACK / VIEW STOCK" if buybacks else "STOCK / BUYBACK (%d)" % game.buyback.size(),func(): buybacks = not buybacks; show_role(role)))
	stock_items = game.buyback.duplicate() if buybacks else game.shops[role].duplicate()
	stock_list = preload("res://scripts/trade_grid.gd").new()
	stock_list.setup(self,stock_items,"buyback" if buybacks else "stock")
	left.add_child(stock_list)
	var paging = HBoxContainer.new()
	left.add_child(paging)
	var page_label = text("1 / %d" % stock_list.pages.size(),14)
	paging.add_child(button("<",func(): stock_list.turn_page(-1); page_label.text = "%d / %d" % [stock_list.page+1,stock_list.pages.size()]))
	paging.add_child(page_label)
	paging.add_child(button(">",func(): stock_list.turn_page(1); page_label.text = "%d / %d" % [stock_list.page+1,stock_list.pages.size()]))
	buy_button = button("BUY SELECTED",buy_selected)
	buy_button.disabled = true
	left.add_child(buy_button)
	var center = VBoxContainer.new()
	columns.add_child(center)
	center.add_child(text("BACKPACK / SELL",18))
	sell_items = []
	for item in game.inventory:
		if not game.Backpack.worn(item,game.equipment): sell_items.append(item)
	sell_list = preload("res://scripts/trade_grid.gd").new()
	sell_list.setup(self,sell_items,"bag")
	center.add_child(sell_list)
	center.add_child(text("12 x 8 / YOUR BACKPACK",13))
	sell_button = button("SELL SELECTED",sell_selected)
	sell_button.disabled = true
	center.add_child(sell_button)
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(306,365)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	columns.add_child(scroll)
	card_host = VBoxContainer.new()
	card_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(card_host)
	body.add_child(text(game.message if game.message_time > 0 else "",13))
	card_host.add_child(text("SALVAGE EXCHANGE\n\nHover to inspect.\nSelect a part, then Buy or Sell.\n\nWorn gear stays protected.\nBuyback keeps the exact part.",14))

func preview(entry: Dictionary, origin: String):
	for child in card_host.get_children():
		card_host.remove_child(child)
		child.queue_free()
	var item: Dictionary = entry.item if origin == "buyback" else entry
	var price: int = entry.price if origin == "buyback" else (game.Economy.value(item) if origin == "bag" else game.Economy.price(item))
	card_host.add_child(text(("SELL / +" if origin == "bag" else "BUY / ")+str(price)+" SILICON",19))
	var card = Card.new()
	card.setup(item,false,"Click item to select")
	card_host.add_child(card)

func preview_selected():
	if not chosen.is_empty(): preview(chosen,source)

func choose(entry: Dictionary, origin: String):
	chosen = entry
	source = origin
	preview(entry,origin)
	var item: Dictionary = entry.item if origin == "buyback" else entry
	var price: int = entry.price if origin == "buyback" else game.Economy.price(item)
	buy_button.disabled = origin == "bag" or game.silicon < price
	sell_button.disabled = origin != "bag"
	buy_button.text = "BUY / %d Si" % price if origin != "bag" else "BUY SELECTED"
	sell_button.text = "SELL / +%d Si" % game.Economy.value(item) if origin == "bag" else "SELL SELECTED"
	if origin == "bag": stock_list.deselect_all()
	else: sell_list.deselect_all()

func buy_selected():
	if chosen.is_empty(): return
	if source == "stock": game.buy_item(chosen)
	elif source == "buyback": game.buy_back(chosen)
	show_role(game.menu_open)

func sell_selected():
	if source == "bag" and not chosen.is_empty(): game.sell_item(chosen)
	show_role(game.menu_open)

func debugger():
	body.add_theme_constant_override("separation",5)
	body.add_child(text("DEV ONLY / Sandbox overrides. Apply sets exact values, resets XP, and restores Life/Mana.\nThese controls are not progression rewards. System menu can reset the character.",15))
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation",24)
	body.add_child(grid)
	debug_fields = {}
	var values = {"level":game.progression.level,"points":game.progression.points,"silicon":game.silicon}
	values.merge(game.progression.attributes)
	for key in values:
		grid.add_child(text(key.capitalize(),17))
		var spin = SpinBox.new()
		spin.custom_minimum_size.x = 240
		spin.min_value = 0 if key in ["points","silicon"] else 1
		spin.max_value = 999999 if key == "silicon" else (9999 if key == "points" else (99 if key == "level" else 999))
		spin.step = 1
		spin.value = values[key]
		grid.add_child(spin)
		debug_fields[key] = spin
	var actions = HBoxContainer.new()
	body.add_child(actions)
	for entry in [["potions","POTIONS: MAX 99/99"],["unlock","UNLOCK ALL WAYPOINTS"],["reset_waypoints","RESET WAYPOINTS + ENCOUNTERS"]]:
		actions.add_child(button(entry[1],func(): game.debug_action(entry[0]); show_role("debug")))
	body.add_child(text("Waypoint reset clears field loot and Wormhole; keeps your character. Cleared floors: %d/19" % game.keycards.size(),13))
	var seed_row = seed_controls()
	seed_row.add_child(button("ENTER DEBUG ARENA",func(): game.debug_action("arena")))
	var samples = HBoxContainer.new()
	body.add_child(samples)
	samples.add_child(button("VISCERAL SAMPLES",func(): game.debug_action("visceral_samples")))
	samples.add_child(button("DRACONIC SAMPLES",func(): game.debug_action("draconic_samples")))
	samples.add_child(button("GIVE ELEMENT / RARITY TEST KIT",func(): game.debug_action("samples")))
	body.add_child(button("APPLY DEV VALUES + REFILL",func():
		var settings = {}
		for key in debug_fields: settings[key] = int(debug_fields[key].value)
		game.debug_apply(settings)
		show_role("debug")))

func tower_map(role: String):
	body.add_theme_constant_override("separation",5)
	body.add_child(text("ACT I / OBESECAT ARCLIGHT" + (" / COMPLETE" if game.act_complete else ""),19))
	body.add_child(text("Garage > Lobby/Concourse > Maintenance > Research > Restaurant > Gardens > Penthouse",15))
	body.add_child(text("Fixed security and loot tiers. Supervisors carry keycards. V is a map; travel requires an elevator.",13))
	var grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation",14)
	body.add_child(grid)
	for id in ["hub"] + game.Tower.ORDER:
		var unlocked = id == "hub" or game.keycards.has(id)
		var title: String = "B1 / Garage Refuge" if id == "hub" else "%d–%d / %s" % [game.Tower.ZONES[id].level,game.Tower.ZONES[id].level+2,game.Tower.ZONES[id].section]
		grid.add_child(text(("> " if game.area == id else "")+title,16))
		grid.add_child(text("SAFE" if id == "hub" else "FLOOR %d / %s" % [game.Tower.ZONES[id].level,"KEYCARD" if unlocked else "LOCKED"],13))
		var go = button("TRAVEL" if unlocked else "KEYCARD NEEDED",func(): game.travel_zone(id,true))
		go.disabled = role != "elevator" or not unlocked or id == game.area
		grid.add_child(go)
	body.add_child(text("19 / ObeseCat Showdown — ascend from Penthouse 18. Side annexes remain optional.",14))
	body.add_child(text("Current: " + ("Garage Refuge" if game.area == "hub" else game.Tower.ZONES.get(game.area,{}).get("name","Test chamber")),14))
	if game.area == "hub":
		body.add_child(button("NEW SORTIE / RESPAWN FLOORS + CLEAR FLOOR LOOT",func(): game.new_sortie(); show_role(role)))
	else: body.add_child(text("Floor damage, corpses and loot persist until a new sortie. No disk saves yet.",13))

func system_menu():
	body.add_child(button("RESUME",func(): game.close_contact()))
	game.hud.fx_button = button("",func(): game.toggle_fx())
	body.add_child(game.hud.fx_button)
	game.hud.sound_button = button("",func(): game.toggle_sound())
	body.add_child(game.hud.sound_button)
	body.add_child(text("C  Character     I  Inventory     V  Map     B  Wormhole\nZ  Life potion     X  Mana potion     Esc  System\nClick / WASD  Move     Click / Space  Attack     E  Interact / Loot\nQ  Empower     Wheel  Zoom     T  Recover after defeat",17))
	body.add_child(button("RESET CHARACTER / TOWER...",func(): game.menu_open = "reset_confirm"; show_role("reset_confirm")))
	body.add_child(text("Session only / no disk saves. Tech Demo 0.14",13))
	game.hud.update_hud()

func arena_controls():
	body.add_theme_constant_override("separation",5)
	seed_controls()
	body.add_child(text("TEST RANGE / 500 Life targets / no combat rewards",18))
	body.add_child(text("Stationary: holds position. Chasing: follows without attacking.\nAttacking: pursues and strikes. Chest tiers 1–5 restock on every use.",16))
	for entry in [["stationary","SPAWN STATIONARY"],["chasing","SPAWN CHASING"],["attacking","SPAWN ATTACKING"],["kit","GIVE FOUR WEAPON SAMPLES"],["bases","GIVE CYBERNETIC BASE SAMPLES"],["clear","CLEAR ENEMIES + FLOOR LOOT"],["reset","RESET RANGE + REFILL LIFE / MANA"]]:
		body.add_child(button(entry[1],func(): preload("res://scripts/debug_arena.gd").action(game,entry[0])))
	body.add_child(button("RETURN TO GARAGE",func(): game.restart(false,true,"hub")))

func seed_controls() -> HBoxContainer:
	var row = HBoxContainer.new()
	body.add_child(row)
	row.add_child(text("WORLD SEED",13))
	var seed_field = SpinBox.new()
	seed_field.name = "WorldSeed"
	seed_field.min_value = 1
	seed_field.max_value = 2147483646
	seed_field.step = 1
	seed_field.value = game.run_seed
	seed_field.custom_minimum_size.x = 180
	row.add_child(seed_field)
	var apply_button = button("APPLY SEED",func(): game.apply_world_seed(int(seed_field.value)))
	apply_button.tooltip_text = "Rebuilds encounters and field loot. Keeps character, carried gear, Silicon and keycards. Same seed replays generation."
	row.add_child(apply_button)
	var random_button = button("RANDOMIZE",func(): game.apply_world_seed(game.WorldRandom.fresh(game.run_seed)))
	random_button.tooltip_text = apply_button.tooltip_text
	row.add_child(random_button)
	return row

func dispatch_quest():
	body.add_child(text("DISPATCH / QUESTS",20))
	if game.chef_quest == "locked":
		body.add_child(text("Climb the tower. Dispatch will contact you when you enter\nRestaurant & Lounge on floor 10.",17))
	else:
		body.add_child(text("DEFEAT THE CHEFBOT",22))
		body.add_child(text("Disable ChefBot on Restaurant & Lounge floor 12.\nIts Unique ChefBot Hat drops directly in the encounter.",17))
		match game.chef_quest:
			"available": body.add_child(button("ACCEPT QUEST",func(): game.chef_quest = "active"; refresh_quest_marker(); show_role("dispatch")))
			"active": body.add_child(text("ACTIVE / ChefBot awaits on floor 12.",18))
			"defeated": body.add_child(button("REPORT CHEFBOT DEFEATED",func(): game.chef_quest = "complete"; refresh_quest_marker(); show_role("dispatch")))
			"complete": body.add_child(text("COMPLETE / ChefBot neutralized.",18))

func refresh_quest_marker():
	for contact in game.interactables:
		if contact.role == "dispatch" and contact.node.has_meta("quest_marker"):
			contact.node.get_meta("quest_marker").visible = false
