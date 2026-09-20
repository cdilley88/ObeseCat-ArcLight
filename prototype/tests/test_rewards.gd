extends SceneTree
const Game = preload("res://scripts/main.gd")
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
	preload("res://tests/legacy_kit.gd").install(g)
	g.start_run()
	check(g.chests.size() == 3,"three randomized field containers")
	for kind in range(4):
		for seed_value in range(30):
			var chest = g.Chests.create(g,kind,Vector3.ZERO,seed_value)
			check(chest.items.size() == (0 if kind == 0 else (2 if kind == 3 else 1)),"container equipment budget")
			for item in chest.items:
				check(item.tier <= 1,"early chest rarity cap survives hero progression")
				if kind == 3: check(item.tier == 1,"early superchest guarantees green")
	var contact = {}
	for entry in g.interactables:
		if entry.role == "chest": contact = entry; break
	check(not g.Chests.open(g,contact),"distant opening refused")
	g.player.position = contact.node.position
	var wallet = g.silicon
	check(g.Chests.open(g,contact),"near container opens")
	var earned = g.silicon
	check(earned >= wallet and not g.Chests.open(g,contact) and g.silicon == earned,"one-time payout")
	var pos = contact.chest.pos
	g.cast_wormhole()
	g.use_wormhole()
	g.cast_wormhole()
	var found = false
	for entry in g.interactables:
		if entry.role == "chest" and entry.chest.pos == pos:
			found = entry.chest.opened and not g.Chests.open(g,entry)
	check(found,"opened chest persists across portal trip")
	var boss = g.enemies[-1]
	g.hit_enemy(boss,99999)
	var count = g.chests.size()
	check(count == 4 and g.chests[-1].kind == 3,"boss creates superchest")
	g.hit_enemy(boss,99999)
	check(g.chests.size() == count,"boss cannot duplicate chest")
	g.restart(false,false,"run")
	var a = g.enemies[1]
	var b = g.enemies[2]
	a.node.position = Vector3(0,0,0)
	b.node.position = Vector3(1,0,0)
	g.apply_enemy_damage(a,10,"radiation")
	g.update_statuses(1.01)
	check(b.burn > 0 and not b.spread,"radiation spreads locally once without infinite chain")
	g.restart(false,false,"run")
	a = g.enemies[1]
	a.dodge = 0
	g.apply_enemy_damage(a,10,"gravity")
	check(is_equal_approx(a.hp,52-10-1.56),"gravity percentage component")
	a.hp = 10000
	a.max_hp = 10000
	g.apply_enemy_damage(a,10,"gravity")
	check(a.hp == 9985,"gravity percent component capped by flat hit")
	g.apply_enemy_damage(a,10,"corruption")
	check(a.weaken > 0 and a.hp >= 9970 and a.hp <= 9980,"corruption random range and weakening")
	g.equipment.head = g.Loot.make_item("head",0,g.rng,false)
	g.damage_player(10,"corruption")
	check(g.current_stats().armor < g.progression.derive(g.Loot.stats(g.equipment)).armor,"corruption lowers player armor")
	g.update_statuses(3.1)
	check(g.player_status.weaken == 0,"temporary weakening expires")
	for element in g.Loot.ELEMENTS:
		g.restart(false,false,"run")
		g.equipment.head = g.Loot.make_item("head",0,g.rng,false)
		var before = g.hp
		g.damage_player(30,element,false)
		var unprotected = before-g.hp
		g.hp = before
		g.equipment.head[element] = 75
		g.damage_player(30,element,false)
		check(before-g.hp < unprotected,"resistance mitigates "+element)
		g.equipment.head[element] = 150
		check(g.current_stats()[element] == 75,"resistance cap "+element)
	g.restart(false)
	g.menu_open = "debug"
	var items = g.inventory.size()
	check(g.debug_action("samples") and g.inventory.size() == items+11,"debug grants six element and five rarity samples")
	g.toggle_character()
	check(g.hud.character_tabs.get_tab_count() == 4 and g.hud.resistance_values.size() == 6,"four character pages and six resistance rows")
	print("REWARD/ELEMENT CHECKS: ",checks," / failures: ",failures)
	g.queue_free()
	await process_frame
	quit(1 if failures else 0)

