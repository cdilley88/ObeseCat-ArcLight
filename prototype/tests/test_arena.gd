extends SceneTree
const Game = preload("res://scripts/main.gd")
const TestArena = preload("res://scripts/debug_arena.gd")
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
	g.menu_open = "debug"
	check(g.debug_action("arena"),"debug teleport authorized")
	check(g.area == "debug_arena" and g.chests.size() == 5,"separate arena with five tiers")
	var wallet = g.silicon
	for contact in g.interactables:
		if contact.role != "chest": continue
		g.player.position = contact.node.position
		check(g.Chests.open(g,contact),"opens arena chest")
		check(not g.Chests.open(g,contact),"debounces double opening")
		contact.chest.ready_at = 0
		check(g.Chests.open(g,contact),"restocks repeatedly")
		if contact.chest.kind == 4:
			check(contact.chest.items.size() == 3,"hoard awards three equipment pieces")
			for item in contact.chest.items: check(item.tier >= 3,"hoard high rarity floor")
	g.menu_open = "arena_control"
	TestArena.action(g,"clear")
	check(g.drops.is_empty(),"clear removes chest floor loot")
	for behavior in ["stationary","chasing","attacking"]:
		g.menu_open = "arena_control"
		TestArena.action(g,behavior)
		check(g.enemies.back().behavior == behavior,"explicit test behavior")
	var target = g.enemies[0]
	g.player.position = Vector3.ZERO
	target.node.position = Vector3(0,0,-2)
	var before = target.node.position
	g.update_enemy(target,1.0)
	check(target.node.position == before,"stationary holds position")
	var chase = g.enemies[1]
	chase.node.position = Vector3(0,0,1)
	g.update_enemy(chase,0.1)
	check(chase.state != "windup","chasing never attacks")
	g.enemies[2].node.position = Vector3(0,0,-1)
	g.update_enemy(g.enemies[2],0.1)
	check(g.enemies[2].state == "windup","attacking winds up")
	g.enemies[2].node.position = Vector3(0,0,2)
	g.attack_victim = target
	var weapon = g.Loot.make_item("weapon",4,g.rng,false)
	weapon.type = "physical"
	var behind = g.enemies[2].hp
	g.melee_sweep(weapon,40,Color.MAGENTA)
	check(target.hp == 460,"cleaver hits forward target")
	check(g.enemies[2].hp == behind,"cleaver does not hit behind player")
	var hp_before = target.hp
	g.launch_missile(target.node.position,50,{"type":"physical","splash":2.1})
	check(target.hp == hp_before,"missile damage waits for travel")
	for i in range(40): g.update_effects(0.025)
	check(target.hp == hp_before-50,"missile explodes at destination")
	wallet = g.silicon
	g.hit_enemy(target,10000)
	check(g.silicon == wallet and g.progression.level == 1 and g.keycards.is_empty(),"test kill gives no campaign rewards")
	g.menu_open = "arena_control"
	TestArena.action(g,"reset")
	check(g.enemies.is_empty() and g.drops.is_empty() and g.chests.size() == 5,"reset rebuilds clean range")
	g.restart(false,true,"hub")
	check(g.area == "hub","return to refuge")
	print("ARENA / WEAPON CHECKS: ",checks," / failures: ",failures)
	g.queue_free()
	await process_frame
	quit(1 if failures else 0)
