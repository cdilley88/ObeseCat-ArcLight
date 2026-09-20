extends SceneTree
const Game = preload("res://scripts/main.gd")
var checks = 0
var failures = 0
func check(ok: bool, why: String):
	checks += 1
	if not ok: failures += 1; push_error("FAIL: "+why)
func _initialize(): call_deferred("run")
func contact(game, role: String) -> Dictionary:
	for entry in game.interactables:
		if entry.role == role: return entry
	return {}
func visit(game,role: String):
	var npc = contact(game,role)
	game.player.position = npc.node.position+Vector3(0,0,1)
	game.interact(npc)
func run():
	var game = Game.new()
	game.run_seed = 170126
	root.add_child(game)
	game.sound_enabled = false
	game.set_physics_process(false)
	game.begin()
	preload("res://tests/legacy_kit.gd").install(game)
	await process_frame
	await physics_frame
	check(game.area == "hub" and game.enemies.is_empty(),"new characters spawn safely in town")
	check(game.interactables.size() == 8,"six contacts plus stairs and elevator")
	check(game.silicon == 80 and game.run_number == 0,"initial currency and run state")
	for entry in game.interactables: check(not game.make_path(game.player.position,entry.node.position).is_empty(),"every contact has reachable navigation endpoint")
	var life: float = game.hp
	game.damage_player(999)
	check(game.hp == life,"hub safe from combat damage")
	game.interact(contact(game,"weapons"))
	check(game.menu_open == "","distant NPC cannot trade")
	visit(game,"weapons")
	check(game.menu_open == "weapons" and game.paused,"near NPC opens paused vendor")
	check(not game.sell_item(game.equipment.left),"worn weapon cannot be sold")
	var item: Dictionary = game.inventory[1]
	var money: int = game.silicon
	var value: int = game.Economy.value(item)
	var item_count: int = game.inventory.size()
	check(game.sell_item(item),"sell backpack item")
	check(game.silicon == money+value and game.inventory.size() == item_count-1,"sale exchanges exact value and removes ownership")
	check(not game.sell_item(item) and game.silicon == money+value,"duplicate sale refused")
	var entry: Dictionary = game.buyback[0]
	check(is_same(entry.item,item),"buyback retains exact item identity")
	check(game.buy_back(entry),"recover sold item")
	check(game.silicon == money and game.Backpack.index_of(game.inventory,item) >= 0,"buyback exactly reverses sale")
	check(not game.buy_back(entry),"stale buyback refused")
	var stock: Dictionary = game.shops.weapons[0]
	game.silicon = 0
	check(not game.buy_item(stock) and game.Backpack.index_of(game.inventory,stock) < 0,"insufficient currency does not transfer stock")
	game.silicon = 999
	var price: int = game.Economy.price(stock)
	check(game.buy_item(stock) and game.silicon == 999-price,"purchase charges exact amount")
	check(not game.buy_item(stock),"stale stock cannot be purchased twice")
	var bought_index: int = game.Backpack.index_of(game.inventory,stock)
	check(bought_index >= 0,"purchase is physically in bag")
	check(game.sell_item(stock) and game.silicon < 999,"buy/resell cannot create currency")
	while game.add_to_backpack(game.Loot.make_item("neck",0,game.rng,false)): pass
	stock = game.shops.weapons[0]
	money = game.silicon
	check(not game.buy_item(stock) and game.silicon == money,"full bag purchase charges nothing")
	entry = game.buyback[-1]
	check(not game.buy_back(entry) and game.silicon == money,"full bag buyback charges nothing")
	game.close_contact()
	check(not game.sell_item(game.inventory[0]),"trade APIs refuse out-of-vendor calls")
	check(not game.debug_apply({"silicon":999}),"debug requires debug NPC")
	game.restart(false)
	preload("res://tests/legacy_kit.gd").install(game)
	visit(game,"debug")
	check(game.debug_apply({"level":8,"points":12,"strength":31,"dexterity":20,"vitality":15,"energy":18,"silicon":1200}),"debug sets requested fields")
	check(game.progression.level == 8 and game.progression.xp == 0 and game.progression.attributes.strength == 31 and game.silicon == 1200,"exact debug values applied")
	check(game.hp == game.current_stats().max_life and game.mana == game.current_stats().max_mana,"debug refills resources")
	game.debug_apply({"level":-100,"silicon":-1,"strength":999999,"points":-4})
	check(game.progression.level == 1 and game.silicon == 0 and game.progression.attributes.strength == 999 and game.progression.points == 0,"debug clamps bounds")
	game.debug_apply({"strength":1})
	for slot in ["left","right"]: game.equipment[slot] = game.Loot.empty_item(slot)
	check(game.current_stats().damage >= 1,"low debug Strength cannot yield negative bare damage")
	game.restart(false)
	preload("res://tests/legacy_kit.gd").install(game)
	visit(game,"armor")
	var sold: Dictionary = game.inventory[1]
	game.sell_item(sold)
	money = game.silicon
	var retained = game.equipment.left
	var dropped: Dictionary = game.inventory[2]
	game.close_contact()
	game.drop_inventory_item(2)
	visit(game,"gate")
	check(game.area == "lobby" and game.run_number == 1 and game.enemies.size() == 7,"stairs enter lobby")
	check(game.silicon == money and is_same(game.equipment.left,retained),"run preserves currency and equipment")
	check(game.buyback.size() == 1 and is_same(game.buyback[0].item,sold),"buyback survives travel")
	check(not game.debug_apply({"silicon":999}),"debug refused during run")
	game.repeat_chamber()
	check(game.area == "lobby","T cannot skip floor travel")
	for enemy in game.enemies: game.hit_enemy(enemy,99999)
	check(game.won and game.silicon == money+30,"kills award bounded Silicon")
	game.hit_enemy(game.enemies[0],99999)
	check(game.silicon == money+30,"duplicate kill grants no Silicon")
	check(game.keycards.has("lobby"),"supervisor grants Lobby keycard")
	game.travel_zone("hub")
	check(game.area == "hub" and game.progression.level == 2 and game.silicon == money+30,"return preserves earned progress")
	check(game.player_status.burn == 0 and game.pending_hits.is_empty(),"travel clears combat effects")
	check(game.drops.size() == 1 and is_same(game.drops[0].item,dropped),"town floor items survive travel")
	game.player.position = game.drops[0].node.position
	game.collect_nearby()
	check(game.Backpack.index_of(game.inventory,dropped) >= 0,"restored floor part recoverable")
	visit(game,"armor")
	check(game.buy_back(game.buyback[0]),"other vendor can recover original sale after run")
	game.close_contact()
	visit(game,"gate")
	check(game.run_number == 1 and game.living_enemies() == 0,"revisit retains cleared encounters")
	game.hp = 0
	game.repeat_chamber()
	check(game.area == "hub" and game.hp == game.current_stats().max_life,"defeat returns to safe recovered hub")
	game.restart(false)
	preload("res://tests/legacy_kit.gd").install(game)
	check(game.silicon == 80 and game.progression.level == 1 and game.buyback.is_empty() and game.run_number == 0,"full reset resets economy and character")
	print("HUB RULE CHECKS: ",checks," / failures: ",failures)
	game.queue_free()
	await process_frame
	quit(1 if failures else 0)

