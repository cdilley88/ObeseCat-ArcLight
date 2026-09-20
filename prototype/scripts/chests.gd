extends RefCounted
const Models = preload("res://scripts/models.gd")
const Loot = preload("res://scripts/loot.gd")
const Tower = preload("res://scripts/tower.gd")
const NAMES = ["LOCKBOX","EQUIPMENT CASE","SALVAGE CHEST","SUPERCHEST","ACT BOSS HOARD"]
const COLORS = [Color("e0e6e5"),Color("57ddeb"),Color("a98aff"),Color("f064cd"),Color("ffce66")]
static func create(game, kind: int, pos: Vector3, seed_value: int) -> Dictionary:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	var level: int = 10 if game.area == "debug_arena" else Tower.ZONES[game.area].level
	var cap: int = 4 if game.area == "debug_arena" else Tower.ZONES[game.area].cap
	var items: Array = []
	if kind > 0:
		for i in range(3 if kind == 4 else (2 if kind == 3 else 1)):
			var tier = 0
			var roll = 1.0-pow(1.0-rng.randf(),1.0+clampf(game.current_stats().item_discovery,0,300)/100.0)
			if kind == 1: tier = 0 if roll < 0.8 else (1 if roll < 0.97 else cap)
			if kind == 2: tier = 0 if roll < 0.25 else (1 if roll < 0.65 else cap)
			if kind == 3: tier = maxi(1,cap-1) if roll < 0.7 else cap
			if kind == 4: tier = cap if roll > 0.65 else maxi(1,cap-1)
			var item = Loot.salvage(rng,level) if game.area == "debug_arena" else Tower.salvage(rng,game.area)
			items.append(Loot.make_item(item.slot,item.model,rng,true,level,mini(cap,tier)))
	return {"kind":kind,"pos":pos,"opened":false,"items":items,"silicon":rng.randi_range(level+3,level*3+12) if kind == 0 or rng.randf()<0.65 else 0,"life":rng.randi_range(1,2) if rng.randf()<0.6 else 0,"mana":1 if rng.randf()<0.45 else 0}

static func build(game, data: Dictionary):
	var node = Node3D.new()
	game.dynamic.add_child(node)
	node.position = data.pos
	var color: Color = COLORS[data.kind]
	var dimensions: Vector3 = [Vector3(0.9,0.4,0.65),Vector3(1.2,0.6,0.8),Vector3(1.5,0.85,1.0),Vector3(1.8,1.05,1.2),Vector3(2.2,1.35,1.5)][data.kind]
	Models.box(node,Vector3(0,dimensions.y/2,0),dimensions,Color("344650"))
	var lid = Models.box(node,Vector3(0,dimensions.y+0.08,0),Vector3(dimensions.x+0.1,0.16,dimensions.z+0.1),color,data.kind >= 3)
	if data.kind >= 2:
		for side in [-1,1]: Models.box(node,Vector3(side*dimensions.x*0.37,dimensions.y/2,dimensions.z*0.51),Vector3(0.12,dimensions.y,0.08),color,data.kind >= 3)
	if data.opened: lid.rotation.x = -0.9; lid.position.z = -0.3
	else:
		Models.box(node,Vector3(0,dimensions.y*0.5,dimensions.z*0.51),Vector3(0.24,0.35,0.06),color,true)
	for band in range(data.kind):
		Models.ring(node,dimensions.x*0.6+band*0.12,Color(color,0.20+band*0.08))
	if data.kind == 4:
		for side in [-1,1]:
			Models.cylinder(node,Vector3(side*0.95,1.2,0),0.12,0.9,color,true)
	if data.kind >= 3:
		var halo = Models.ring(node,1.1,color)
		node.set_meta("halo",halo)
	var label = Models.text3d(node,NAMES[data.kind]+(" / OPEN" if data.opened else " [E]"),Vector3(0,dimensions.y+0.65,0),color,22)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.pixel_size = 0.014
	game.interactables.append({"role":"chest","node":node,"chest":data,"lid":lid,"label":label})
	game.chests.append(data)

static func populate(game):
	if game.zone_states.has(game.area): return
	var bounds = Tower.bounds(game.area)
	var seed_value: int = game.WorldRandom.derive(game.run_seed,game.run_number,game.area,"field_chests")
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	var spots = [Vector3(bounds.position.x+3,0,bounds.end.y-5),Vector3(bounds.end.x-3,0,bounds.position.y+5),Vector3(bounds.position.x+4,0,bounds.position.y+3)]
	for i in range(3):
		var kind = rng.randi_range(0,2)
		build(game,create(game,kind,spots[i],seed_value+i*347))

static func open(game, contact: Dictionary) -> bool:
	if not game.interactables.has(contact) or game.hp <= 0 or game.player.position.distance_to(contact.node.position) > 2.2: return false
	var data: Dictionary = contact.chest
	if data.get("repeatable",false):
		if Time.get_ticks_msec() < data.get("ready_at",0): return false
		game.arena_open_counts[data.kind] = int(game.arena_open_counts.get(data.kind,0))+1
		data.sequence = game.WorldRandom.derive(game.run_seed,0,"debug_arena","chest_"+str(data.kind),game.arena_open_counts[data.kind])
		var fresh = create(game,data.kind,data.pos,data.sequence)
		for key in ["items","silicon","life","mana"]: data[key] = fresh[key]
		data.opened = false
		data["ready_at"] = Time.get_ticks_msec()+500
	if data.opened: return false
	data.opened = true
	contact.lid.rotation.x = -0.9
	contact.lid.position.z = -0.3
	contact.label.text = NAMES[data.kind]+(" / RESTOCKED [E]" if data.get("repeatable",false) else " / OPEN")
	game.silicon += Loot.Bonuses.silicon(data.silicon,game.current_stats().silicon_discovery)
	var life = game.add_potions("life",data.life)
	var mana = game.add_potions("mana",data.mana)
	for i in range(data.items.size()): game.spawn_drop(data.pos+Vector3((i-0.5)*0.8,0,0.9),data.items[i])
	game.toast("%s / +%d Silicon / +%d Life, +%d Mana potions" % [NAMES[data.kind],Loot.Bonuses.silicon(data.silicon,game.current_stats().silicon_discovery),life,mana],4)
	return true
