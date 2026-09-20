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
	check(g.Tower.FLOOR_ORDER.size() == 19,"19 main floors")
	for i in range(19):
		var id: String = g.Tower.FLOOR_ORDER[i]
		check(g.Tower.ZONES[id].level == i+1,"fixed floor difficulty index")
		check(g.Tower.ZONES[id].next == (g.Tower.FLOOR_ORDER[i+1] if i < 18 else ""),"connected upward floor link")
	for family in g.Tower.ORDER:
		var index: int = g.Tower.FLOOR_ORDER.find(family)
		var layouts = {}
		for i in range(3): layouts[var_to_str(g.Tower.covers(g.Tower.FLOOR_ORDER[index+i],12,1))] = true
		check(layouts.size() == 3,"three different layouts per area")
	g.restart(false,true,"research_3")
	check(g.chef_quest == "locked","quest not available before Restaurant")
	g.restart(false,true,"dining")
	check(g.chef_quest == "available","floor 10 unlocks quest")
	g.restart(false,true,"hub")
	var dispatch = {}
	for contact in g.interactables:
		if contact.role == "dispatch": dispatch = contact
	check(dispatch.node.has_meta("quest_marker"),"Dispatch available marker")
	g.chef_quest = "active"
	g.restart(false,true,"dining_3")
	var chef = {}
	for enemy in g.enemies:
		if enemy.type_id == "chefbot": chef = enemy
	check(not chef.is_empty(),"ChefBot spawns on floor 12")
	g.hit_enemy(chef,100000)
	check(g.chef_quest == "defeated","ChefBot defeat updates quest")
	var hat = {}
	for drop in g.drops:
		if drop.item.get("unique_id","") == "chefbot_hat": hat = drop.item
	check(not hat.is_empty(),"ChefBot guaranteed Unique drop")
	check(hat.tier == 5 and hat.affix == "Unique" and hat.affixes.is_empty(),"authored Unique rarity")
	check(hat.armor == 2 and hat.heat == 20 and hat.flat_heat == 5 and hat.life == -15,"exact hat combat stats")
	for key in ["strength","dexterity","vitality","energy"]: check(hat[key] == 3,"+3 attribute "+key)
	var drops = g.drops.size()
	g.hit_enemy(chef,100000)
	check(g.drops.size() == drops,"corpse cannot duplicate Unique")
	g.restart(false,true,"hub")
	g.restart(false,true,"dining_3")
	check(g.drops.size() == drops,"Unique persists with floor loot")
	g.equipment.head = hat
	g.Models.equip(g.pet,g.equipment)
	check(g.current_stats().flat_heat == 5,"flat Heat damage aggregated")
	g.spawn_enemy(Vector3.ZERO,false,100)
	var target = g.enemies.back()
	target.hp = 100; target.max_hp = 100; target.resists = {}; target.dodge = 0
	g.apply_enemy_damage(target,10,"physical")
	check(target.hp == 85,"hat adds five flat Heat to a non-Heat hit")
	var card = preload("res://scripts/item_card.gd").content(hat)
	check("+3 All Stats" in card.bonuses and "+5 Heat damage" in card.bonuses and "-15 Life" in card.bonuses,"compact exact Unique card")
	var definitions = preload("res://scripts/encounters.gd").TYPES
	for type_id in ["laser_turret","laser_patrol","rocket_sentry","blade_chaser"]:
		g.spawn_enemy(Vector3(5,0,5),false,100,type_id)
		var enemy = g.enemies.back()
		check(enemy.type_id == type_id and enemy.element == definitions[type_id].element,"sentry definition wiring")
		g.player.position = Vector3(5,0,4)
		g.update_enemy(enemy,0.1)
		check(enemy.state == "aim","sentry telegraphs attack")
	g.restart(false,true,"obesecat")
	var obese = g.enemies.back()
	check(obese.type_id == "obesecat","ObeseCat showdown on 19")
	g.hit_enemy(obese,100000)
	check(g.act_complete,"ObeseCat ends Act I")
	g.restart(false)
	check(g.chef_quest == "locked","full character reset clears quest")
	print("ARCLIGHT ACT I CHECKS: ",checks," / failures: ",failures)
	g.queue_free()
	await process_frame
	quit(1 if failures else 0)
