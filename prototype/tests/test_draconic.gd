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
	var rng = RandomNumberGenerator.new()
	rng.seed = 7414
	var total = 0
	for kind in Loot.BASES:
		for base in range(Loot.BASES[kind].size()):
			if Loot.BASES[kind][base].get("affinity","") != "Draconic": continue
			total += 1
			for tier in range(5):
				var item = Loot.make_item(kind,base,rng,true,10,tier)
				check(item.affinity == "Draconic" and item.tier == tier,"affinity survives modifier rolls")
				check(item.affixes.size() == [0,1,2,3,3][tier],"same rarity modifier budgets")
				check(ResourceLoader.exists(item.icon),"Draconic art imported")
	check(total == 13,"13 authored Draconic bases")
	for kind in ["head","weapon"]:
		for base in range(Loot.BASES[kind].size()):
			if Loot.BASES[kind][base].get("affinity","") == "Visceral":
				var item = Loot.make_item(kind,base,rng,true,10,4)
				check(item.affinity == "Visceral" and item.affixes.size() == 3 and ResourceLoader.exists(item.icon),"Visceral rolls and artwork")
	for preferred in ["Cybernetic","Draconic","","Visceral"]:
		var matches = 0
		var seen = {}
		for i in range(10000):
			var base = Loot.pick_base(rng,"weapon",preferred)
			var family = Loot.BASES.weapon[base].get("affinity","Cybernetic")
			if family == "Draconic": matches += 1
			seen[base] = true
		check(seen.size() == 13,"all weapons reachable for each source")
		var expected = 8500 if preferred == "Draconic" else (750 if preferred == "Cybernetic" else (750 if preferred == "Visceral" else 3333))
		check(abs(matches-expected) < 250,"matching bias or neutral fallback distribution")
	var g = Game.new()
	root.add_child(g)
	g.set_physics_process(false)
	g.sound_enabled = false
	g.begin()
	check(g.inventory.size() == 1 and g.equipment.left.model == 1 and g.equipment.left.tier == 0,"only white Phase blade starts equipped")
	for slot in Loot.SLOTS:
		if slot != "left": check(g.equipment[slot].model == -1,"other starter slots empty")
	g.restart(false,true,"debug_arena")
	g.player.position = Vector3.ZERO
	g.spawn_enemy(Vector3(0,0,-3),false,100)
	var front = g.enemies.back()
	g.spawn_enemy(Vector3(3,0,0),false,101)
	var outside = g.enemies.back()
	for enemy in [front,outside]:
		enemy.hp = 100; enemy.max_hp = 100; enemy.dodge = 0; enemy.resists = {}
	g.attack_victim = front
	var breath = Loot.make_item("weapon",7,rng,false)
	g.breath_attack(breath,10,Loot.TYPES.heat)
	check(front.hp == 90,"Breath damages in-cone enemy once")
	check(outside.hp == 100,"Breath excludes enemy outside cone")
	check(g.effects.size() >= 20,"Breath creates spread particles")
	g.restart(false,true,"hub")
	g.menu_open = "debug"
	g.debug_action("draconic_samples")
	check(g.drops.size() == 13,"developer sampler exposes all Draconic bases")
	print("DRACONIC CHECKS: ",checks," / failures: ",failures)
	g.queue_free()
	await process_frame
	quit(1 if failures else 0)
