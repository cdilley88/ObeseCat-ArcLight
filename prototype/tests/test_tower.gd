extends SceneTree
const Game = preload("res://scripts/main.gd")
var checks = 0
var failures = 0
func check(ok: bool, why: String):
	checks += 1
	if not ok: failures += 1; push_error("FAIL: "+why)
func _initialize(): call_deferred("run")
func clear_floor(game):
	for enemy in game.enemies: game.hit_enemy(enemy,99999)
func run():
	var game = Game.new()
	game.run_seed = 170126
	root.add_child(game)
	game.sound_enabled = false
	game.set_physics_process(false)
	game.begin()
	await process_frame
	var previous_hp = 0.0
	for id in game.Tower.FLOOR_ORDER:
		check(game.Tower.profile(id,false).hp > previous_hp,"main route difficulty increases: "+id)
		previous_hp = game.Tower.profile(id,false).hp
	for id in game.Tower.ZONES:
		game.restart(false,true,id)
		await physics_frame
		check(game.area_bounds().get_area() > game.BOUNDS.get_area(),"larger exploration area: "+id)
		check(not game.astar.is_point_solid(game.grid_cell(game.player.position)),"clear entry: "+id)
		for enemy in game.enemies:
			check(not game.astar.is_point_solid(game.grid_cell(enemy.node.position)),"clear enemy spawn: "+id+str(enemy.index))
			check(not game.make_path(game.player.position,enemy.node.position).is_empty(),"enemy reachable: "+id+str(enemy.index))
		for door in game.interactables:
			check(not game.make_path(game.player.position,door.node.position).is_empty(),"exit reachable: "+id+door.role)
		for i in range(80):
			var part: Dictionary = game.Tower.salvage(game.rng,id)
			check(part.tier <= game.Tower.ZONES[id].cap,"fixed rarity ceiling: "+id)
	game.restart(false,true,"archive")
	game.player.position = game.FAULT
	var before_fault: float = game.hp
	game.fault_time = 6.19
	game.update_fault(0.02)
	check(game.hp < before_fault and game.fault_fired,"archive fault has a live corruption pulse")
	game.restart(false,true,"obesecat")
	for entry in game.interactables:
		if entry.role == "ceo_terminal":
			game.player.position = entry.node.position
			game.interact(entry)
	check(not game.act_complete,"CEO terminal stays locked before supervisor")
	game.restart(false)
	game.start_run()
	check(game.area == "lobby","garage enters lobby")
	check(not game.travel_zone("maintenance"),"supervisor locks onward stairs")
	game.open_tower_map()
	check(not game.travel_zone("hub",true),"read-only map cannot teleport")
	game.close_contact()
	var original_hp = game.enemies[1].hp
	game.hit_enemy(game.enemies[0],99999)
	game.hit_enemy(game.enemies[1],5)
	var wallet = game.silicon
	var saved_hp = game.enemies[1].hp
	var part = game.Loot.make_item("head",0,game.rng,false)
	game.spawn_drop(game.player.position,part)
	check(game.travel_zone("hub"),"stairs allow retreat")
	game.progression.level = 99
	game.start_run()
	check(game.enemies[0].hp <= 0 and game.enemies[1].hp == saved_hp,"corpses and enemy damage survive return")
	check(game.enemies[1].max_hp == original_hp,"level 99 does not scale early enemies")
	game.hit_enemy(game.enemies[0],99999)
	check(game.silicon == wallet,"restored corpse cannot pay twice")
	var found = false
	for drop in game.drops:
		if is_same(drop.item,part): found = true
	check(found,"floor item identity retained")
	clear_floor(game)
	check(game.keycards.has("lobby") and game.keycards.size() == 1,"supervisor unlocks one elevator keycard")
	game.hp = 17
	game.mana = 8
	game.heal_charges = 0
	check(game.travel_zone("concourse"),"optional branch accessible")
	check(game.hp == 17 and game.mana == 8 and game.heal_charges == 0,"stairs do not refill resources")
	clear_floor(game)
	check(not game.keycards.has("concourse"),"side areas do not grant main elevator cards")
	check(game.travel_zone("lobby"),"branch reconnects to parent")
	check(game.player.position.x == game.Tower.bounds("lobby").end.x-4,"branch return uses matching doorway")
	check(game.travel_zone("lobby_2"),"keycard unlocks forward route")
	game.open_tower_map(true)
	check(not game.travel_zone("gardens",true),"locked elevator destination refused")
	check(game.travel_zone("hub",true),"physical elevator returns to garage")
	check(game.hp == game.current_stats().max_life,"garage replenishes resources")
	wallet = game.silicon
	check(game.new_sortie(),"new sortie available at garage")
	check(game.zone_states.is_empty() and game.keycards.has("lobby") and game.silicon == wallet,"sortie resets floors, retains access and character")
	game.open_tower_map(true)
	check(game.travel_zone("lobby",true),"unlocked elevator stop revisitable")
	check(game.living_enemies() == 7 and game.drops.is_empty(),"new sortie actually respawns and clears old floor loot")
	check(game.enemies[0].hp == original_hp,"new sortie early enemies remain weak at level 99")
	check(not game.new_sortie(),"no mid-floor reset")
	# Complete connected main route using explicit test-only damage, not a balance playtest.
	for id in game.Tower.FLOOR_ORDER:
		check(game.area == id,"connected route reached "+id)
		clear_floor(game)
		check(game.keycards.has(id),"keycard recovered "+id)
		var next: String = game.Tower.ZONES[id].get("next","")
		if next != "": check(game.travel_zone(next),"onward transition "+next)
	for entry in game.interactables:
		if entry.role == "ceo_terminal":
			game.player.position = entry.node.position+Vector3(0,0,1)
			game.interact(entry)
	check(game.act_complete,"CEO terminal completes act after encounter")
	game.restart(false)
	check(game.keycards.is_empty() and game.zone_states.is_empty() and not game.act_complete,"full reset clears act state")
	print("TOWER RULE CHECKS: ",checks," / failures: ",failures)
	game.queue_free()
	await process_frame
	quit(1 if failures else 0)

