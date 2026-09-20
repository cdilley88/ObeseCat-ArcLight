extends SceneTree
const Game = preload("res://scripts/main.gd")
const Loot = preload("res://scripts/loot.gd")
var checks = 0
var failures = 0
func check(ok: bool, why: String):
	checks += 1
	if not ok: failures += 1; push_error(why)
func _initialize(): call_deferred("run")
func run():
	var g = Game.new()
	g.run_seed = 170126
	root.add_child(g)
	g.sound_enabled = false
	g.set_physics_process(false)
	g.begin()
	g.equipment.neck = Loot.make_item("neck",0,g.rng,false)
	var rng = RandomNumberGenerator.new()
	rng.seed = 91234
	var seen = {}
	var affixes = {}
	var special_counts = [0,0,0,0,0]
	for i in range(5000):
		var item = g.Tower.salvage(rng,"ceo")
		seen[item.slot+str(item.model)] = true
	for kind in Loot.BASES:
		for model in range(Loot.BASES[kind].size()):
			check(seen.has(kind+str(model)),"drop coverage "+kind+str(model))
			var item = Loot.make_item(kind,model,rng,false)
			check(ResourceLoader.exists(item.icon),"unique icon exists "+item.name)
			if kind == "head": check(item.width == 2 and item.height == 2,"all helmets 2x2")
	for tier in range(1,5):
		for i in range(1500):
			var item = Loot.make_item("neck",2,rng,true,8,tier)
			var unique = {}
			for mod in item.affixes:
				unique[mod.key] = true
				affixes[mod.key] = true
			if item.affixes[0].key in Loot.SPECIAL: special_counts[tier] += 1
			if unique.size() != item.affixes.size(): check(false,"duplicate affix")
	for key in Loot.Bonuses.ALL: check(affixes.has(key),"rollable modifier "+key)
	check(special_counts[4] > special_counts[1]*2,"rarity weights favor specialized rolls")
	var a = RandomNumberGenerator.new()
	var b = RandomNumberGenerator.new()
	a.seed = 98; b.seed = 98
	var basic = 0
	var boosted = 0
	for i in range(10000):
		basic += Loot.roll_tier(a,8,0)
		boosted += Loot.roll_tier(b,8,100)
	check(boosted > basic,"Item Discovery improves quality distribution")
	for i in range(100):
		if g.Tower.salvage(rng,"lobby",300).tier > 1: check(false,"discovery bypassed area cap")
	check(Loot.Bonuses.silicon(20,50) == 30,"Silicon Discovery payout")
	g.restart(false,true,"debug_arena")
	g.spawn_enemy(Vector3(0,0,-2),false,0)
	var target = g.enemies[0]
	target.hp = 1000; target.max_hp = 1000; target.resists = {}; target.dodge = 0
	g.equipment.neck["damage_heat"] = 50.0
	g.equipment.neck["slayer_cybernetic"] = 20.0
	g.apply_enemy_damage(target,10,"heat")
	check(is_equal_approx(target.hp,982),"element and affinity damage bonuses affect hit")
	g.hp = 100
	g.damage_player(30,"physical",false,"Cybernetic")
	var unguarded = 100-g.hp
	g.hp = 100
	g.equipment.neck["guard_cybernetic"] = 30.0
	g.equipment.neck["flat_reduction"] = 3.0
	g.damage_player(30,"physical",false,"Cybernetic")
	check(100-g.hp < unguarded-3,"affinity and flat mitigation")
	g.hp = 100
	g.equipment.neck["elemental_reduction"] = 4.0
	g.damage_player(30,"heat",false)
	var protected = 100-g.hp
	g.hp = 100
	g.equipment.neck.elemental_reduction = 0
	g.damage_player(30,"heat",false)
	check(is_equal_approx(100-g.hp-protected,4),"flat elemental mitigation")
	g.equipment.neck["mana_regen"] = 2.0
	g.equipment.neck["life_regen"] = 2.0
	check(g.current_stats().mana_regen == 5,"mana regen includes equipment")
	g.hp = 40; g.mana = 10
	g.enemies.clear()
	g._physics_process(0.5)
	check(g.hp == 41 and g.mana == 12.5,"resources actually regenerate")
	g.equipment.neck["melee_arc"] = 50.0
	g.equipment.neck["projectile_range"] = 50.0
	g.equipment.neck["explosion_radius"] = 50.0
	var blade = Loot.make_item("weapon",1,rng,false)
	var gun = Loot.make_item("weapon",0,rng,false)
	check(is_equal_approx(g.weapon_reach(blade),3.45) and g.weapon_reach(gun) == 9,"melee/projectile reach")
	g.launch_missile(Vector3.ZERO,10,Loot.make_item("weapon",3,rng,false))
	check(is_equal_approx(g.effects.back().radius,3.15),"explosion radius applies")
	var item = Loot.make_item("neck",2,rng,false)
	item["item_discovery"] = 20
	item["flat_reduction"] = 3
	var card = preload("res://scripts/item_card.gd").content(item)
	check("20% Item Discovery" in card.bonuses and "3 Damage reduced by" in card.bonuses,"item card labels and units")

	g.restart(false,true,"debug_arena")
	var chest_before = 0
	var chest_after = 0
	for seed_value in range(80):
		g.equipment.neck["item_discovery"] = 0
		var low = g.Chests.create(g,3,Vector3.ZERO,seed_value)
		g.equipment.neck.item_discovery = 100
		var high = g.Chests.create(g,3,Vector3.ZERO,seed_value)
		for piece in low.items: chest_before += piece.tier
		for piece in high.items: chest_after += piece.tier
	check(chest_after > chest_before,"chest quality responds to Item Discovery")
	for contact in g.interactables:
		if contact.role != "chest" or contact.chest.kind != 0: continue
		g.player.position = contact.node.position
		g.equipment.neck["silicon_discovery"] = 100
		var wallet = g.silicon
		g.Chests.open(g,contact)
		check(g.silicon-wallet == contact.chest.silicon*2,"chest payout uses Silicon Discovery")
	var sale_item = Loot.make_item("head",2,rng,false)
	var price = g.Economy.value(sale_item)
	g.equipment.neck.silicon_discovery = 300
	check(g.Economy.value(sale_item) == price,"discovery does not inflate sale price")
	print("EXPANDED SALVAGE CHECKS: ",checks," / failures: ",failures)
	g.queue_free()
	await process_frame
	quit(1 if failures else 0)

