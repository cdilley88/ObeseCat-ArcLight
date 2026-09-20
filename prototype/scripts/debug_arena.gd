extends RefCounted
const Models = preload("res://scripts/models.gd")
const Chests = preload("res://scripts/chests.gd")
const Hub = preload("res://scripts/hub.gd")
static func build(game):
	Models.box(game.arena,Vector3(0,-0.2,0),Vector3(20.5,0.4,16.5),Color("26333e"))
	for x in range(-10,11,2): Models.box(game.arena,Vector3(x,0.02,0),Vector3(0.025,0.02,16),Color("477078"))
	for z in range(-8,9,2): Models.box(game.arena,Vector3(0,0.02,z),Vector3(20,0.02,0.025),Color("477078"))
	for i in range(5):
		var data = Chests.create(game,i,Vector3(-8+i*4,0,-5.5),game.WorldRandom.derive(game.run_seed,0,"debug_arena","chest_"+str(i),int(game.arena_open_counts.get(i,0))))
		data["repeatable"] = true
		data["sequence"] = game.WorldRandom.derive(game.run_seed,0,"debug_arena","chest_"+str(i),int(game.arena_open_counts.get(i,0)))
		Chests.build(game,data)
	var operator = Node3D.new()
	game.dynamic.add_child(operator)
	operator.position = Vector3(4,0,5)
	operator.add_child(Models.pet())
	Models.ring(operator,0.9,Color("7af1d7"))
	var label = Models.text3d(operator,"RANGE OPERATOR [E]",Vector3(0,2,0),Color("7af1d7"),24)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.pixel_size = 0.015
	game.interactables.append({"role":"arena_control","node":operator})
	Hub.gate(game,Vector3(-4,0,5),"arena_exit","RETURN / GARAGE",Color("8fdcc6"))
static func action(game, action_name: String):
	if game.area != "debug_arena" or game.menu_open != "arena_control": return
	if action_name == "reset":
		game.restart(false,true,"debug_arena")
		game.hp = game.current_stats().max_life
		game.mana = game.current_stats().max_mana
		return
	if action_name == "clear":
		for enemy in game.enemies: enemy.node.queue_free()
		for drop in game.drops: drop.node.queue_free()
		for effect in game.effects: effect.node.queue_free()
		game.enemies.clear()
		game.drops.clear()
		game.effects.clear()
		game.pending_hits.clear()
		game.target_enemy = {}
		game.target_drop = {}
		game.attack_victim = {}
		game.attack_weapon = {}
		game.attack_windup = -1
		game.path.clear()
		game.toast("Range cleared",2)
	elif action_name == "bases":
		for kind in ["head","neck","barding","harness","locomotion"]:
			for model in range(game.Loot.BASES[kind].size()):
				if game.Loot.BASES[kind][model].get("affinity","Cybernetic") != "Cybernetic": continue
				var item = game.Loot.make_item(kind,model,game.rng,false)
				if not game.add_to_backpack(item): game.spawn_drop(game.player.position+Vector3((model%3)*0.8,0,int(model/3)*0.8),item)
		game.hud.refresh_inventory()
		game.toast("Cybernetic bases delivered; overflow stays on the floor",4)
	elif action_name == "kit":
		for model in [0,1,3,4]:
			var item = game.Loot.make_item("weapon",model,game.rng,false)
			if not game.add_to_backpack(item): game.spawn_drop(game.player.position,item)
		game.hud.refresh_inventory()
		game.toast("Four white weapon samples delivered; overflow on floor",3)
	elif action_name in ["stationary","chasing","attacking"]:
		if game.enemies.size() >= 12:
			game.toast("12 test units maximum. Clear the range first."); return
		game.spawn_enemy(Vector3(-3+(game.enemies.size()%4)*2,0,-1+int(game.enemies.size()/4)*1.6),false,game.enemies.size())
		var enemy: Dictionary = game.enemies.back()
		enemy["behavior"] = action_name
		enemy.hp = 500.0
		enemy.max_hp = 500.0
		enemy.resists = {}
		enemy.dodge = 0.0
		enemy.title = action_name.to_upper()
		enemy.label.text = enemy.title+" / 500"
		enemy.state = "hunt"
		game.close_contact()

