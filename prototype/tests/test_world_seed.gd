extends SceneTree
const Game = preload("res://scripts/main.gd")
const Randomness = preload("res://scripts/world_random.gd")
const Encounters = preload("res://scripts/encounters.gd")
var checks = 0
var failures = 0
func check(ok: bool, why: String):
	checks += 1
	if not ok: failures += 1; push_error(why)
func _initialize(): call_deferred("run")
func arena_roll(g) -> String:
	for contact in g.interactables:
		if contact.role == "chest" and contact.chest.kind == 4:
			g.player.position = contact.node.position
			contact.chest.ready_at = 0
			g.Chests.open(g,contact)
			return var_to_str(contact.chest.items)
	return ""
func run():
	var g = Game.new()
	g.run_seed = 170126
	root.add_child(g)
	g.begin()
	g.set_physics_process(false)
	g.sound_enabled = false
	check(not g.apply_world_seed(42),"seed changes require developer menu")
	g.menu_open = "debug"
	g.keycards = ["lobby"]
	var gear = g.equipment.left
	var wallet = g.silicon
	check(g.apply_world_seed(42),"explicit seed accepted")
	check(g.keycards == ["lobby"] and is_same(g.equipment.left,gear) and g.silicon == wallet,"character ownership and unlocks retained")
	g.restart(false,true,"debug_arena")
	var first = arena_roll(g)
	g.restart(false,true,"hub")
	g.restart(false,true,"debug_arena")
	var second = arena_roll(g)
	check(first != second,"arena re-entry continues chest sequence")
	g.menu_open = "arena_control"
	g.apply_world_seed(42)
	check(arena_roll(g) == first,"applying same seed replays chest sequence")
	g.menu_open = "arena_control"
	g.apply_world_seed(43)
	check(arena_roll(g) != first,"different seed changes chest content")
	var stream_a = Randomness.stream(42,1,"lobby","enemy_loot",3)
	var expected = g.Tower.salvage(stream_a,"lobby")
	for i in range(400): g.rng.randf()
	var stream_b = Randomness.stream(42,1,"lobby","enemy_loot",3)
	check(var_to_str(g.Tower.salvage(stream_b,"lobby")) == var_to_str(expected),"combat RNG cannot perturb enemy loot")
	var changed = g.Tower.salvage(Randomness.stream(43,1,"lobby","enemy_loot",3),"lobby")
	check(var_to_str(changed) != var_to_str(expected),"new world seed changes enemy equipment")
	check(Randomness.fresh(42) != 42,"randomization excludes current seed")
	for id in g.Tower.ZONES:
		g.restart(false,true,id)
		var descriptors = Encounters.regions(g.Tower.bounds(id),id in g.Tower.FLOOR_ORDER)
		var walkable = func(pos: Vector3) -> bool:
			return not g.astar.is_point_solid(g.grid_cell(pos)) and not g.make_path(g.Tower.spawn(id),pos).is_empty()
		var previous = ""
		for seed_value in [42,43,44,1001]:
			var plan = Encounters.plan(seed_value,1,id,descriptors,walkable)
			check(plan.size() == descriptors.size(),"all encounter regions populated "+id)
			check(var_to_str(plan) == var_to_str(Encounters.plan(seed_value,1,id,descriptors,walkable)),"placement replay "+id)
			if previous != "": check(previous != var_to_str(plan),"placement changes with seed "+id)
			previous = var_to_str(plan)
			for entry in plan:
				check(walkable.call(entry.pos),"spawn reachable "+id)
				check(Encounters.TYPES.has(entry.type),"registered enemy type")
	g.restart(false,true,"hub")
	g.wormhole = {"area":"lobby","pos":Vector3.ZERO}
	g.menu_open = "debug"
	check(not g.apply_world_seed(0),"invalid seed rejected")
	g.apply_world_seed(100)
	check(g.zone_states.is_empty() and g.wormhole.is_empty() and g.arena_open_counts.is_empty(),"new seed invalidates old generated state")
	print("WORLD SEED CHECKS: ",checks," / failures: ",failures)
	g.queue_free()
	await process_frame
	quit(1 if failures else 0)
