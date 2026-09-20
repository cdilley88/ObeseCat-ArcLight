extends SceneTree
const Loot = preload("res://scripts/loot.gd")
const Game = preload("res://scripts/main.gd")
const Bag = preload("res://scripts/backpack.gd")
var checks = 0
var failures = 0
func check(ok: bool, why: String):
	checks += 1
	if not ok: failures += 1; push_error("FAIL: " + why)
func _initialize(): call_deferred("run")
func find_item(game, slot: String, model: int) -> int:
	for i in range(game.inventory.size()):
		if game.inventory[i].slot == slot and game.inventory[i].model == model: return i
	return -1
func occupancy(game):
	for item in game.inventory:
		if not Bag.worn(item,game.equipment): check(Bag.can_place(game.inventory,game.equipment,item,item.grid_pos),"bag has no overlap / out of bounds")
func run():
	var rng = RandomNumberGenerator.new()
	var twin = RandomNumberGenerator.new()
	rng.seed = 404
	twin.seed = 404
	for i in range(100): check(Loot.salvage(rng,8) == Loot.salvage(twin,8),"seeded salvage reproducible")
	for kind in Loot.BASES:
		for base in range(Loot.BASES[kind].size()):
			var white = Loot.make_item(kind,base,rng,false,12)
			check(white.tier == 0 and white.affixes.is_empty(),"white has zero random modifiers")
			check(ResourceLoader.exists(white.icon),"every base has actual inventory art")
			for tier in range(1,5):
				var item = Loot.make_item(kind,base,rng,true,8,tier)
				check(item.affixes.size() == [0,1,2,3,3][tier],"tier bonus count")
				if tier >= 3: check(item.affixes[2].key in Loot.SPECIAL,"rare has distinct special bonus")
	var distribution = [0,0,0,0,0]
	for i in range(10000): distribution[Loot.roll_tier(rng,8)] += 1
	check(distribution[3] > 5000 and distribution[4] < 300 and distribution[4] > 100,"late lab distribution mostly violet; magenta outlier")
	print("LEVEL 8 RARITY SAMPLE / 10000: ",distribution)
	var game = Game.new()
	game.run_seed = 170126
	root.add_child(game)
	game.restart(false,false,"run")
	preload("res://tests/legacy_kit.gd").install(game)
	game.set_physics_process(false)
	game.sound_enabled = false
	game.begin()
	preload("res://tests/legacy_kit.gd").install(game)
	await process_frame
	await physics_frame
	check(game.inventory.size() == 18 and game.equipment.size() == 8,"18 bases / 8 slots")
	check(Bag.used_cells(game.inventory,game.equipment) <= 96,"white kit fits")
	occupancy(game)
	check(game.clear_shot(Vector3(-6,0,1),Vector3(-6,0,3)),"open line of fire")
	check(not game.clear_shot(Vector3(-2.7,0,-1.5),Vector3(-2.7,0,1.5)),"cover blocks fire")
	check(not game.make_path(Vector3(-6,0,1),Vector3(0,0,-2)).is_empty(),"navigation around cover")
	var laser = find_item(game,"weapon",0)
	var blade = find_item(game,"weapon",1)
	var cannon = find_item(game,"weapon",2)
	check(game.equip_item(blade,"right"),"light weapon in right")
	check(not is_same(game.equipment.left,game.equipment.right),"independent light slots")
	check(game.equip_item(cannon,"left"),"heavy displaces both")
	check(is_same(game.equipment.left,game.equipment.right),"heavy occupies both")
	check(not Bag.worn(game.inventory[laser],game.equipment) and not Bag.worn(game.inventory[blade],game.equipment),"both lights safely bagged")
	occupancy(game)
	check(game.current_stats().damage == game.inventory[cannon].damage,"heavy counted once")
	game.auto_pack()
	check(game.equip_item(laser,"right"),"light replaces heavy from either slot")
	check(game.equipment.left.model == -1,"heavy frees other slot")
	check(not game.equip_item(blade,"head"),"wrong category rejected")
	game.auto_pack()
	check(game.equip_item(cannon,"right"),"heavy equip on right")
	game.auto_pack()
	check(game.unequip_item(cannon),"heavy unequip")
	check(game.equipment.left.model == -1 and game.equipment.right.model == -1,"both slots cleared on unequip")
	check(game.current_stats().damage == 4,"bare strike fallback")
	game.equip_item(cannon)
	check(game.drop_inventory_item(cannon),"drop equipped heavy")
	check(game.equipment.left.model == -1 and game.equipment.right.model == -1,"drop clears both")
	var drop: Dictionary = game.drops[-1]
	game.pickup(drop)
	var n: int = game.inventory.size()
	game.pickup(drop)
	check(game.inventory.size() == n,"repeat pickup never duplicates")
	game.restart(false,false,"run")
	preload("res://tests/legacy_kit.gd").install(game)
	# Fill every free cell; preserve original big cannon footprint.
	game.equip_item(find_item(game,"weapon",1),"right")
	while true:
		var filler = Loot.make_item("neck",0,rng,false)
		if not game.add_to_backpack(filler): break
	check(Bag.used_cells(game.inventory,game.equipment) == 96,"all 96 cells usable")
	var blocked: int = find_item(game,"weapon",2)
	# two 1x3 displaced weapons fit in freed 2x4 rectangle even when otherwise full
	check(game.equip_item(blocked),"heavy swap fits two light parts in freed footprint")
	occupancy(game)
	# Conversely a 2x4 heavy cannot fit in only the selected 1x3 rectangle.
	var light: int = find_item(game,"weapon",0)
	while true:
		if not game.add_to_backpack(Loot.make_item("neck",0,rng,false)): break
	var before = game.equipment.duplicate()
	check(not game.equip_item(light,"right"),"failed heavy-to-light replacement is atomic")
	check(is_same(game.equipment.left,before.left) and is_same(game.equipment.right,before.right),"failed swap preserves both equipped references")
	check(not game.unequip_item(blocked),"full bag cannot unequip heavy")
	var ground = Loot.make_item("barding",1,rng,false)
	game.spawn_drop(game.player.position,ground)
	game.pickup(game.drops[-1])
	check(game.drops.size() == 1 and Bag.index_of(game.inventory,ground) == -1,"full pickup stays ground")
	check(not game.move_inventory_item(light,Vector2i(-1,0)),"negative placement rejected")
	check(not game.move_inventory_item(light,Vector2i(12,8)),"out of bounds rejected")
	game.restart(false,false,"run")
	preload("res://tests/legacy_kit.gd").install(game)
	var original = game.inventory.duplicate(true)
	game.auto_pack()
	occupancy(game)
	game.restart(false,false,"run")
	preload("res://tests/legacy_kit.gd").install(game)
	check(game.inventory == original,"reset reproducible")
	var stale = {"kind":"inventory_item","game":game,"index":0,"item":game.inventory[0],"offset":Vector2i.ZERO}
	game.restart(false,false,"run")
	preload("res://tests/legacy_kit.gd").install(game)
	check(not game.hud.inventory_grid.valid_data(stale),"stale drag refused")
	# Resources, gear bonuses, and clamping when capacity is removed.
	game.award_xp(150)
	check(game.progression.level == 3 and game.progression.points == 10,"XP multi-level and points")
	var old_max: float = game.current_stats().max_life
	game.spend_attribute("vitality")
	check(game.current_stats().max_life == old_max+5 and game.progression.points == 9,"allocation works")
	var magic = Loot.make_item("neck",0,rng,false)
	magic.vitality = 4.0
	magic.energy = 3.0
	magic.strength = 2.0
	game.add_to_backpack(magic)
	game.equip_item(game.inventory.size()-1)
	check(game.current_stats().max_life == old_max+25,"equipment vitality grants Life")
	check(game.current_stats().max_mana == 70,"equipment energy and base Mana")
	game.hp = game.current_stats().max_life
	game.mana = game.current_stats().max_mana
	game.unequip_item(game.inventory.size()-1)
	check(game.hp <= game.current_stats().max_life and game.mana <= game.current_stats().max_mana,"removal clamps resource caps")
	# Matrix Circuit keeps recipe order and replacement rules.
	game.equip_item(find_item(game,"matrix",1))
	for i in range(3): game.cycle_socket(i)
	check(game.current_stats().circuit,"matrix Circuit activated")
	var enemy: Dictionary = game.enemies[0]
	enemy.node.position = game.player.position + Vector3(1,0,0)
	game.charge = 1.5
	game.damage_player(12)
	check(enemy.hp == 28 and game.circuit_cooldown == 5,"Circuit damage and cooldown")
	game.damage_player(12)
	check(enemy.hp == 28,"Circuit no repeat during cooldown")
	# Damage themes and mitigation.
	game.restart(false,false,"run")
	preload("res://tests/legacy_kit.gd").install(game)
	enemy = game.enemies[1]
	enemy.node.position = game.player.position + Vector3(1,0,0)
	game.apply_enemy_damage(enemy,10,"radiation")
	check(enemy.hp == 42 and enemy.burn == 3,"Radiation initial hit and burn")
	game.update_statuses(1.01)
	check(enemy.hp < 42,"Radiation ticks over time")
	enemy.burn = 0
	game.apply_enemy_damage(enemy,1,"radiation")
	check(is_equal_approx(enemy.burn_damage,0.08),"expired stronger burn does not boost later weak burn")
	for i in range(3): game.apply_enemy_damage(enemy,1,"cryogenic")
	check(enemy.slow > 0 and enemy.stop > 0,"Cryogenic slow and third-hit freeze")
	game.restart(false,false,"run")
	preload("res://tests/legacy_kit.gd").install(game)
	enemy = game.enemies[1]
	enemy.node.position = game.player.position + Vector3(1,0,0)
	enemy.dodge = 0
	game.apply_enemy_damage(enemy,10,"gravity",7.5)
	game.update_statuses(0.23)
	game.update_statuses(0.23)
	check(is_equal_approx(enemy.hp,52-10-52*0.03),"Gravity adds percentage Life component")
	game.apply_enemy_damage(enemy,10,"gravity",7.5)
	enemy.node.position = game.player.position + Vector3(15,0,0)
	var health: float = enemy.hp
	game.update_statuses(0.5)
	check(enemy.hp == health,"Gravity has no legacy delayed hits")
	enemy.node.position = game.player.position + Vector3(1,0,0)
	enemy.dodge = 1.0
	game.apply_enemy_damage(enemy,5,"gravity",7.5)
	health = enemy.hp
	game.update_statuses(0.5)
	check(enemy.hp == health,"Gravity leaves no delayed strike queue")
	game.restart(false,false,"run")
	preload("res://tests/legacy_kit.gd").install(game)
	var before_hp: float = game.hp
	game.damage_player(20,"radiation",false)
	var unprotected = before_hp-game.hp
	game.hp = before_hp
	game.equip_item(find_item(game,"head",1))
	game.damage_player(20,"radiation",false)
	check(before_hp-game.hp < unprotected,"Radiation resistance mitigates damage")
	game.damage_player(10,"cryogenic")
	check(game.player_status.slow > 0 and game.player_status.stop > 0,"hazard status applies to player")
	game.restart(false,false,"run")
	preload("res://tests/legacy_kit.gd").install(game)
	for base in range(4):
		check(game.equip_item(find_item(game,"locomotion",base)),"locomotion equips")
		check(game.pet.get_node("Gear/Locomotion").get_child_count() > 0,"visible locomotion geometry")
		for child in game.pet.get_children():
			if str(child.name).begins_with("Leg"): check(child.visible == (base == 0),"native legs visibility matches mode")
	game.restart(false,false,"run")
	preload("res://tests/legacy_kit.gd").install(game)
	game.equip_item(find_item(game,"weapon",1),"right")
	check(game.selected_weapon().model == 0,"first alternating light attack")
	enemy = game.enemies[0]
	enemy.node.position = game.player.position+Vector3(1,0,0)
	game.request_attack(enemy)
	check(game.selected_weapon().model == 1,"second alternating light attack")
	check(game.attack_cooldown < 0.6,"light fast cadence")
	game.attack_cooldown = 0
	game.equip_item(find_item(game,"weapon",2))
	game.request_attack(enemy)
	check(game.attack_cooldown > 1.4,"heavy slow cadence")
	# Resource/XP regression cases retained as the equipment schema changes.
	var P = preload("res://scripts/progression.gd")
	var progress = P.new()
	check(progress.gain_xp(-1) == 0 and progress.xp == 0,"negative XP ignored")
	check(not progress.spend("strength"),"no point debt")
	progress.gain_xp(50)
	check(not progress.spend("invalid") and progress.points == 5,"invalid attribute rejected")
	for attribute in P.ATTRIBUTES: check(progress.spend(attribute),"all four stats allocatable")
	game.restart(false,false,"run")
	preload("res://tests/legacy_kit.gd").install(game)
	enemy = game.enemies[1]
	enemy.node.position = game.player.position+Vector3(1,0,0)
	game.toggle_empowered()
	var mana_before: float = game.mana
	game.request_attack(enemy)
	game.resolve_attack()
	check(game.mana == mana_before-10 and not game.empowered,"empowered hit spends once")
	game.attack_cooldown = 0
	game.attack_windup = -1
	game.toggle_empowered()
	enemy.node.position = game.player.position+Vector3(15,0,0)
	game.attack_victim = enemy
	game.resolve_attack()
	check(game.mana == mana_before-10 and game.empowered,"missed empowered hit costs nothing")
	game.paused = true
	game._physics_process(1.0)
	check(game.mana == mana_before-10,"pause stops Mana regen")
	game.paused = false
	game.hp = 0
	game.award_xp(50)
	check(game.hp == 0,"level up cannot resurrect")
	game.restart(false,false,"run")
	preload("res://tests/legacy_kit.gd").install(game)
	enemy = game.enemies[0]
	game.hit_enemy(enemy,9999)
	var xp_before: int = game.progression.xp
	game.hit_enemy(enemy,9999)
	check(game.progression.xp == xp_before,"duplicate kill awards no XP")
	game.restart(false,false,"run")
	preload("res://tests/legacy_kit.gd").install(game)
	var signature = Loot.signature_item(rng)
	game.add_to_backpack(signature)
	game.equip_item(game.inventory.size()-1,"left")
	game.enemies[0].node.position = game.player.position+Vector3(1,0,0)
	game.enemies[1].node.position = game.player.position+Vector3(2,0,0)
	game.request_attack(game.enemies[0])
	game.resolve_attack()
	check(game.enemies[0].hp < 52 and game.enemies[1].hp < 52,"retained experimental Signature secondary hit")
	game.restart(false,false,"run")
	preload("res://tests/legacy_kit.gd").install(game)
	# Repeat retains items + level; reset clears combat/status and restores kit.
	game.award_xp(50)
	game.won = true
	var retained = game.inventory[0]
	game.repeat_chamber()
	check(game.progression.level == 2 and is_same(retained,game.inventory[0]),"repeat retains build")
	check(game.pending_hits.is_empty() and game.player_status.slow == 0,"repeat clears statuses and queued hits")
	game.restart(false,true,"run")
	for e in game.enemies: game.hit_enemy(e,9999)
	check(game.drops.size() >= 1 and game.drops.size() <= 2,"bounded salvage per chamber")
	game.restart(false,false,"run")
	preload("res://tests/legacy_kit.gd").install(game)
	check(game.progression.level == 1 and game.inventory.size() == 18,"full restart resets progression")
	while not game.inventory.is_empty(): game.drop_inventory_item(0)
	game.hud.refresh_inventory()
	check(game.hud.equip_button.disabled and game.hud.drop_button.disabled,"empty inventory safe UI")
	check(game.current_stats().damage == 4,"all parts removed bare fallback")
	for d in game.drops.duplicate(): game.pickup(d)
	check(game.inventory.size()+game.drops.size() == 18,"all items preserved across drop / pickup, overflow stays ground")
	var Card = preload("res://scripts/item_card.gd")
	var plain = Loot.make_item("weapon",0,rng,false)
	var data = Card.content(plain)
	check(data.totals == "12 Radiation damage" and data.bonuses == "","white weapon concise total without empty bonus lines")
	plain.damage += 5
	plain.affixes.append({"key":"damage","value":5,"role":"primary"})
	data = Card.content(plain)
	check(data.totals == "17 Radiation damage" and data.bonuses == "+5 Damage","rolled damage included once in total, bonus listed once")
	plain = Loot.make_item("matrix",1,rng,false)
	plain.sockets = ["Capacitor","Relay","Empty"]
	data = Card.content(plain)
	check(data.totals == "+2 Damage" and data.bonuses.contains("+0.15 Movement speed"),"card includes loose socket totals with precise speed")
	plain.sockets = Loot.RECIPE.duplicate()
	data = Card.content(plain)
	check(data.totals == "" and data.bonuses == "" and data.effects.contains("Emergency Return"),"Circuit card replaces loose socket stats")
	plain = Loot.make_item("locomotion",3,rng,false)
	data = Card.content(plain)
	check(data.totals == "-1 Defense" and data.bonuses.contains("+0.75"),"negative base tradeoff is visible")
	game.restart(false,false,"run")
	preload("res://tests/legacy_kit.gd").install(game)
	var preview = game.hud.character_preview
	check(not is_same(preview.model,game.pet) and preview.view.own_world_3d,"preview isolated from live actor and world")
	var world_rotation: float = game.pet.rotation.y
	preview.turn(0.5)
	check(game.pet.rotation.y == world_rotation,"preview rotation never rotates world actor")
	var revision: int = preview.revision
	game.equip_item(find_item(game,"locomotion",3))
	check(preview.revision > revision and preview.mode == "hover","equip immediately refreshes preview")
	revision = preview.revision
	game.unequip_item(find_item(game,"locomotion",3))
	check(preview.revision > revision and preview.mode == "paws","unequip immediately restores preview legs")
	game.equip_item(find_item(game,"matrix",1))
	revision = preview.revision
	game.cycle_socket(0)
	check(preview.revision > revision,"socket change refreshes visible preview rings")
	print("SALVAGE RULE CHECKS: ",checks," / failures: ",failures)
	game.queue_free()
	await process_frame
	quit(1 if failures else 0)
