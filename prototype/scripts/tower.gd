extends RefCounted
## Authored area tiers: no player-level inputs anywhere in this module.
const Models = preload("res://scripts/models.gd")
const Hub = preload("res://scripts/hub.gd")
const Loot = preload("res://scripts/loot.gd")
const ORDER = ["lobby","maintenance","research","dining","gardens","ceo"]
const AREA_TEMPLATES = {
 "lobby":{"name":"01 / Lobby & Shopping","level":1,"cap":1,"theme":"lobby","size":Vector2(42,36),"prev":"hub","next":"maintenance","side":"concourse","hp":34.0,"boss_hp":105.0,"damage":7.0,"xp":12,"boss_xp":40,"color":"d7ba7f","boss":"SECURITY SUPERVISOR"},
 "maintenance":{"name":"02 / Maintenance & Housekeeping","level":2,"cap":1,"theme":"maintenance","size":Vector2(44,36),"prev":"lobby","next":"research","side":"conduits","hp":48.0,"boss_hp":145.0,"damage":9.0,"xp":18,"boss_xp":60,"color":"b8bf69","boss":"PLANT FOREMAN"},
 "research":{"name":"03 / Offices & Research","level":4,"cap":2,"theme":"research","size":Vector2(44,38),"prev":"maintenance","next":"dining","side":"archive","hp":68.0,"boss_hp":205.0,"damage":11.0,"xp":28,"boss_xp":90,"color":"73d5d6","boss":"LAB CONTROL UNIT"},
 "dining":{"name":"04 / Restaurant & Lounge","level":6,"cap":3,"theme":"dining","size":Vector2(42,36),"prev":"research","next":"gardens","hp":92.0,"boss_hp":280.0,"damage":13.0,"xp":38,"boss_xp":120,"color":"e2a694","boss":"HOSPITALITY UNIT"},
 "gardens":{"name":"05 / Rooftop Gardens & Spa","level":8,"cap":4,"theme":"gardens","size":Vector2(46,38),"prev":"dining","next":"ceo","hp":120.0,"boss_hp":365.0,"damage":15.0,"xp":48,"boss_xp":150,"color":"93d99b","boss":"GARDEN CUSTODIAN"},
 "ceo":{"name":"06 / CEO Suite","level":10,"cap":4,"theme":"ceo","size":Vector2(34,30),"prev":"gardens","next":"","hp":175.0,"boss_hp":600.0,"damage":18.0,"xp":60,"boss_xp":240,"color":"daa9e5","boss":"EXECUTIVE FIREWALL"},
 "concourse":{"name":"Side / Shuttered Concourse","level":2,"cap":1,"theme":"lobby","size":Vector2(28,24),"prev":"lobby","hp":43.0,"boss_hp":125.0,"damage":8.0,"xp":16,"boss_xp":50,"color":"b29d7b","boss":"STOCKROOM WATCHER"},
 "conduits":{"name":"Side / Utility Conduits","level":3,"cap":2,"theme":"maintenance","size":Vector2(28,24),"prev":"maintenance","hp":58.0,"boss_hp":175.0,"damage":10.0,"xp":23,"boss_xp":70,"color":"b8b968","boss":"PRESSURE REGULATOR"},
 "archive":{"name":"Side / Corrupted Archive","level":5,"cap":3,"theme":"archive","size":Vector2(30,26),"prev":"research","hp":80.0,"boss_hp":245.0,"damage":12.0,"xp":32,"boss_xp":110,"color":"d082da","boss":"MEMORY WARDEN"}
}

const FLOOR_ORDER = ["lobby","lobby_2","lobby_3","maintenance","maintenance_2","maintenance_3","research","research_2","research_3","dining","dining_2","dining_3","gardens","gardens_2","gardens_3","ceo","ceo_2","ceo_3","obesecat"]
static var ZONES: Dictionary = make_zones()
static func make_zones() -> Dictionary:
	var result = {}
	var names = ["Lobby/Concourse","Maintenance & Housekeeping","Research Lab","Restaurant & Lounge","Rooftop Gardens","Penthouse"]
	for i in range(19):
		var area_index = mini(i/3,5)
		var family: String = ORDER[area_index]
		var id: String = FLOOR_ORDER[i]
		var data: Dictionary = AREA_TEMPLATES[family].duplicate(true)
		data["family"] = family
		data["floor"] = i+1
		data.level = i+1
		data["section"] = names[area_index]
		data.name = "%02d / %s" % [i+1,names[area_index]] if i < 18 else "19 / ObeseCat Showdown"
		data.prev = "hub" if i == 0 else FLOOR_ORDER[i-1]
		data.next = "" if i == 18 else FLOOR_ORDER[i+1]
		data.cap = 1 if i < 6 else (2 if i < 9 else (3 if i < 12 else 4))
		data.hp = 34.0+i*8.0
		data.boss_hp = 105.0+i*28.0
		data.damage = 7.0+i*0.8
		data.xp = 12+i*3
		data.boss_xp = 40+i*10
		if i%3 != 0: data.erase("side")
		if id == "dining_3": data.boss = "CHEFBOT"; data.boss_hp = 460.0
		if id == "obesecat": data.boss = "OBESECAT / ARCLIGHT CORE"; data.boss_hp = 1200.0
		result[id] = data
	for id in ["concourse","conduits","archive"]:
		result[id] = AREA_TEMPLATES[id].duplicate(true)
		result[id]["family"] = result[id].prev
		result[id]["floor"] = 0
	return result

static func bounds(id: String) -> Rect2:
	var size: Vector2 = ZONES[id].size
	return Rect2(-size/2,size)

static func spawn(id: String) -> Vector3:
	return Vector3(0,0,bounds(id).end.y-4)

static func covers(id: String, world_seed: int = 170126, sortie: int = 0) -> Array:
	if id in FLOOR_ORDER:
		var layout_rng = preload("res://scripts/world_random.gd").stream(world_seed,sortie,ZONES[id].family,"architecture")
		var variant = (layout_rng.randi_range(0,2)+int(ZONES[id].floor)-1)%3
		if variant == 1: return [Rect2(-13,-7,8,2),Rect2(5,-7,8,2),Rect2(-13,2,8,2),Rect2(5,2,8,2),Rect2(-6,-4,1,4),Rect2(5,5,1,4)]
		if variant == 2: return [Rect2(-12,-6,4,7),Rect2(8,-3,4,7),Rect2(-5,-5,10,1.5),Rect2(-5,5,10,1.5)]
	if id not in FLOOR_ORDER: return [Rect2(-3,-2,6,3),Rect2(-11,-7,3,3),Rect2(8,1,3,3)]
	match ZONES[id].theme:
		"lobby": return [Rect2(-13,-4,6,4),Rect2(7,-4,6,4),Rect2(-3,4,6,2)]
		"maintenance": return [Rect2(-13,-5,4,6),Rect2(9,-5,4,6),Rect2(-4,4,8,2)]
		"research": return [Rect2(-12,-4,6,3),Rect2(6,-4,6,3),Rect2(-12,4,5,2),Rect2(7,4,5,2)]
		"dining": return [Rect2(-12,-5,4,3),Rect2(8,-5,4,3),Rect2(-12,3,4,3),Rect2(8,3,4,3)]
		"gardens": return [Rect2(-4,-3,8,8),Rect2(-15,-5,3,6),Rect2(12,0,3,6)]
		"ceo": return [Rect2(-4,-4,8,3),Rect2(-12,-3,4,3),Rect2(8,-3,4,3)]
	return []

static func profile(id: String, boss: bool) -> Dictionary:
	var z: Dictionary = ZONES[id]
	return {"hp":z.boss_hp if boss else z.hp,"max_hp":z.boss_hp if boss else z.hp,"attack_damage":z.damage+3 if boss else z.damage,"xp_reward":z.boss_xp if boss else z.xp,"silicon_reward":z.level*3+9 if boss else z.level+2,"loot_level":z.level,"loot_cap":z.cap,"title":z.boss if boss else "SECURITY / T%d" % z.level}

static func salvage(rng: RandomNumberGenerator, id: String, discovery: float = 0.0, affinity: String = "") -> Dictionary:
	var z: Dictionary = ZONES[id]
	var kinds = Loot.BASES.keys()
	var kind: String = kinds[rng.randi_range(0,kinds.size()-1)]
	var base = Loot.pick_base(rng,kind,affinity)
	var tier = mini(Loot.roll_tier(rng,z.level,discovery),z.cap)
	return Loot.make_item(kind,base,rng,true,z.level,tier)

static func floor_mesh(parent: Node3D, rect: Rect2, color: Color):
	# Two instanced checker batches instead of thousands of scene nodes.
	for parity in [0,1]:
		var transforms: Array[Transform3D] = []
		for x in range(int(rect.position.x),int(rect.end.x)):
			for z in range(int(rect.position.y),int(rect.end.y)):
				if posmod(x+z,2) == parity: transforms.append(Transform3D(Basis.IDENTITY,Vector3(x+0.5,-0.03,z+0.5)))
		var mesh = BoxMesh.new()
		mesh.size = Vector3(0.98,0.07,0.98)
		var batch = MultiMesh.new()
		batch.transform_format = MultiMesh.TRANSFORM_3D
		batch.mesh = mesh
		batch.instance_count = transforms.size()
		for i in range(transforms.size()): batch.set_instance_transform(i,transforms[i])
		var node = MultiMeshInstance3D.new()
		node.multimesh = batch
		node.material_override = Models.material(color.lightened(0.04*parity))
		parent.add_child(node)

static func exit_gate(game, pos: Vector3, target: String, caption: String, required: String = ""):
	Hub.gate(game,pos,"travel",caption,Color("92d9c9") if required == "" or game.keycards.has(required) else Color("d7a274"))
	game.interactables[-1]["destination"] = target
	game.interactables[-1]["required"] = required

static func build(game, id: String):
	var z: Dictionary = ZONES[id]
	var root: Node3D = game.arena
	var rect = bounds(id)
	var tint = Color(z.color)
	var palettes = {"lobby":Color("454948"),"maintenance":Color("353e37"),"research":Color("35474c"),"dining":Color("44343c"),"gardens":Color("405747"),"ceo":Color("282938"),"archive":Color("343048")}
	floor_mesh(root,rect,palettes[z.theme])
	for x in [rect.position.x,rect.end.x]:
		Models.box(root,Vector3(x,0.7,0),Vector3(0.25,1.4,rect.size.y),tint.darkened(0.55))
		game.obstacle(Vector3(x,1,0),Vector3(0.4,3,rect.size.y))
	for y in [rect.position.y,rect.end.y]:
		Models.box(root,Vector3(0,0.6,y),Vector3(rect.size.x,1.2,0.25),tint.darkened(0.55))
		game.obstacle(Vector3(0,1,y),Vector3(rect.size.x,3,0.4))
	for cover in covers(id,game.run_seed,game.run_number):
		var center = Vector3(cover.get_center().x,0.55,cover.get_center().y)
		game.obstacle(center,Vector3(cover.size.x,1.3,cover.size.y))
		if z.theme == "gardens" and cover.size.x == 8:
			Models.box(root,Vector3(center.x,0.05,center.z),Vector3(8,0.18,8),Color("6ca5a1"))
			Models.box(root,Vector3(center.x,0.16,center.z),Vector3(7.5,0.05,7.5),Color("4ad9ce"),true)
			continue
		Models.box(root,center,Vector3(cover.size.x,1.1,cover.size.y),tint.darkened(0.55))
		match z.theme:
			"lobby":
				Models.box(root,center+Vector3(0,1,0),Vector3(cover.size.x+0.15,0.16,cover.size.y+0.15),tint)
				for offset in [-1,1]: Models.box(root,center+Vector3(offset,0.7,0),Vector3(0.5,0.8,0.6),Color("78b9b4"))
			"maintenance":
				for offset in [-0.8,0,0.8]:
					var pipe = Models.cylinder(root,center+Vector3(offset,0.6,0),0.23,cover.size.y,Color("829064"))
					pipe.rotation.x = PI/2
			"research", "archive":
				for offset in [-1,1]:
					Models.box(root,center+Vector3(offset,0.9,0),Vector3(0.85,0.6,0.25),tint,true)
					Models.cylinder(root,center+Vector3(offset,0.6,0.7),0.25,0.35,Color("657c89"))
			"dining":
				Models.box(root,center+Vector3(0,0.62,0),Vector3(cover.size.x+0.2,0.12,cover.size.y+0.2),Color("b79387"))
				for x in [-1,1]:
					Models.cylinder(root,center+Vector3(x,0.78,0),0.35,0.04,Color("dfd8bf"))
					Models.box(root,center+Vector3(x,0,-2),Vector3(0.7,0.8,0.7),Color("643545"))
			"gardens":
				for x in [-0.7,0.7]:
					Models.cylinder(root,center+Vector3(x,0.9,0),0.1,1.4,Color("7f7851"))
					Models.sphere(root,center+Vector3(x,1.5,0),Vector3(1.8,1.2,1.8),Color("7daa67"))
			"ceo":
				Models.box(root,center+Vector3(0,0.6,0),Vector3(cover.size.x+0.2,0.15,cover.size.y+0.2),Color("97816b"))
				Models.box(root,center+Vector3(0,1,-0.3),Vector3(1.6,0.8,0.2),tint,true)
	# Repeated architecture gives each open section its own silhouette.
	for x in [-1,1]:
		for y in [-8,0,8]:
			var point = Vector3(x*(rect.end.x-1.3),1.4,y)
			if z.theme in ["research","archive"]:
				Models.cylinder(root,point,0.45,2.8,Color("536f7b"))
				Models.cylinder(root,point,0.48,0.4,tint,true)
			elif z.theme in ["lobby","dining","ceo"]:
				Models.box(root,point,Vector3(0.7,2.8,0.7),tint.darkened(0.15))
				Models.box(root,point+Vector3(0,1.4,0),Vector3(1.1,0.15,1.1),tint,true)
			elif z.theme == "gardens":
				Models.sphere(root,point,Vector3(2,2,2),Color("6b9d69"))
			else: Models.box(root,point,Vector3(0.7,2.8,0.7),Color("869269"))
	var sign = Models.text3d(root,z.name.to_upper(),Vector3(0,0.1,rect.end.y-7),tint,38,false)
	sign.rotation_degrees.x = -90
	# Arrival is south. Forward exit is north; branch is east.
	exit_gate(game,Vector3(-4,0,rect.end.y-2.5),z.prev,"BACK / "+("GARAGE" if z.prev == "hub" else ZONES[z.prev].name))
	if id in FLOOR_ORDER:
		if id in ORDER: Hub.gate(game,Vector3(4,0,rect.end.y-3),"elevator","ELEVATOR / KEYCARD",tint)
		if z.next != "": exit_gate(game,Vector3(0,0,rect.position.y+2.5),z.next,"UP / "+ZONES[z.next].name,id)
		else:
			Hub.gate(game,Vector3(0,0,rect.position.y+2.5),"ceo_terminal","ARCLIGHT CORE",tint)
	if z.has("side"): exit_gate(game,Vector3(rect.end.x-2.5,0,3),z.side,ZONES[z.side].name)
	# Build navigation before planning; future room graphs can supply region descriptors.
	game.build_navigation()
	var encounter_rules = preload("res://scripts/encounters.gd")
	var descriptors = encounter_rules.regions(rect,id in FLOOR_ORDER)
	for i in range(descriptors.size()-1):
		descriptors[i].pool = ["laser_turret","laser_patrol","blade_chaser","rocket_sentry"] if ZONES[id].level >= 4 else ["laser_turret","laser_patrol","blade_chaser"]
	if id == "dining_3": descriptors[-1].pool = ["chefbot"]
	if id == "obesecat": descriptors[-1].pool = ["obesecat"]
	var walkable = func(pos: Vector3) -> bool:
		if pos.distance_to(spawn(id)) < 5.0: return false
		for contact in game.interactables:
			if pos.distance_to(contact.node.position) < 2.0: return false
		if game.astar.is_point_solid(game.grid_cell(pos)): return false
		return not game.make_path(spawn(id),pos).is_empty()
	for entry in encounter_rules.plan(game.run_seed,game.run_number,id,descriptors,walkable):
		game.spawn_enemy(entry.pos,entry.boss,entry.index,entry.type)
	game.Chests.populate(game)
	if z.theme == "archive":
		game.build_fault()
		for i in range(5): Models.box(root,Vector3(-4+i*1.8,1.8,-6),Vector3(0.8,0.2,0.8),tint,true)

