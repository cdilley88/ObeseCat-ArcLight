extends RefCounted
const Models = preload("res://scripts/models.gd")
const Loot = preload("res://scripts/loot.gd")
const COVERS = [Rect2(-9,-6,4,3),Rect2(5,-6,4,3),Rect2(-9,1,3,3),Rect2(6,1,3,3),Rect2(-0.7,-0.7,1.4,1.4)]
const CONTACTS = [
	["weapons","WEAPONS",Vector3(-4.2,0,-2.0),Color("e2b572")],
	["armor","ARMOR",Vector3(4.2,0,-2.0),Color("7abac9")],
	["broker","SIGNAL BROKER",Vector3(-5.3,0,2.0),Color("ae8be2")],
	["cosmetics","IDENTITY / STYLE",Vector3(5.3,0,4.8),Color("df91bd")],
	["dispatch","DISPATCH",Vector3(-2.8,0,5.4),Color("d9cd97")],
	["debug","DEV / DEBUG",Vector3(2.8,0,5.4),Color("82ebb2")]]

static func build(game):
	var root: Node3D = game.arena
	Models.box(root,Vector3(0,-0.25,0),Vector3(20.5,0.5,16.5),Color("303b40"))
	for x in range(-10,10):
		for z in range(-8,8):
			var street = abs(x) < 2 or z in [0,-1,4,5]
			Models.box(root,Vector3(x+0.5,0,z+0.5),Vector3(0.97,0.05,0.97),Color("4c5455") if street else Color("343e43"))
	for x in [-10.2,10.2]:
		Models.box(root,Vector3(x,0.6,0),Vector3(0.3,1.2,16.4),Color("465c58"))
		game.obstacle(Vector3(x,0.6,0),Vector3(0.3,2,16.4))
	for z in [-8.2,8.2]: game.obstacle(Vector3(0,0.6,z),Vector3(20.4,2,0.3))
	# Low service vehicles, striped parking bays, exposed concrete: no ceiling obscures the player.
	for i in range(4):
		var rect: Rect2 = COVERS[i]
		var center = Vector3(rect.get_center().x,0.6,rect.get_center().y)
		var color: Color = CONTACTS[i][3]
		Models.box(root,center,Vector3(rect.size.x,1.2,rect.size.y),Color("3d4e53"))
		Models.box(root,center+Vector3(0,0.72,0),Vector3(rect.size.x*0.65,0.35,rect.size.y*0.8),Color("657377"))
		game.obstacle(center,Vector3(rect.size.x,2,rect.size.y))
		for offset in [-0.65,0.65]: Models.box(root,center+Vector3(offset,0.15,rect.size.y/2+0.03),Vector3(0.6,0.25,0.06),color,true)
		for x in [rect.position.x-0.25,rect.end.x+0.25]: Models.box(root,Vector3(x,0.08,rect.get_center().y),Vector3(0.12,0.03,rect.size.y+0.6),Color("c9bd7e"))
	Models.box(root,Vector3(0,1.4,-8.1),Vector3(20.4,2.8,0.3),Color("4d5c61"))
	for x in [-8,8]:
		for z in [-6.8,6.7]:
			Models.box(root,Vector3(x,1.7,z),Vector3(0.65,3.4,0.65),Color("798281"))
			Models.box(root,Vector3(x,0.65,z),Vector3(0.68,0.45,0.68),Color("b8a759"))
			Models.box(root,Vector3(x,3.25,z),Vector3(2,0.08,0.2),Color("b5e6d8"),true)
	for x in [-3,3]:
		Models.box(root,Vector3(x,0.08,-4.8),Vector3(0.18,0.03,1.1),Color("cfb861"))
	# Central warm beacon makes a recognizably safe social space.
	Models.cylinder(root,Vector3(0,0.28,0),0.65,0.56,Color("5d6b62"))
	var beacon = Models.sphere(root,Vector3(0,0.9,0),Vector3(0.55,1.05,0.55),Color("f1b168"))
	beacon.material_override.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var warmth = OmniLight3D.new()
	warmth.position = Vector3(0,1.5,0)
	warmth.light_color = Color("ffbd76")
	warmth.light_energy = 1.3
	warmth.omni_range = 7
	root.add_child(warmth)
	Models.ring(root,0.9,Color("cba466"))
	game.obstacle(Vector3(0,0.6,0),Vector3(1.4,1.2,1.4))
	for x in [-4,4]:
		for z in [-6.7,6.8]:
			Models.cylinder(root,Vector3(x,1.0,z),0.07,2,Color("78918a"))
			Models.box(root,Vector3(x,2.1,z),Vector3(0.4,0.25,0.4),Color("f0d28b"),true)
	for contact in CONTACTS:
		var node = Node3D.new()
		game.dynamic.add_child(node)
		node.position = contact[2]
		var pet = Models.pet()
		node.add_child(pet)
		pet.rotation.y = -2.2
		var kit = {}
		for slot in Loot.SLOTS: kit[slot] = Loot.empty_item(slot)
		kit.head = Loot.make_item("head",1,game.rng,false)
		kit.harness = Loot.make_item("harness",0,game.rng,false)
		Models.equip(pet,kit)
		Models.box(node,Vector3(0.85,0.55,0),Vector3(0.45,1.1,0.55),contact[3])
		Models.ring(node,0.7,contact[3])
		var label = Models.text3d(node,contact[1]+" [E]",Vector3(0,2,0),contact[3],28)
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.no_depth_test = true
		label.pixel_size = 0.019
		game.interactables.append({"node":node,"role":contact[0]})
		if contact[0] == "dispatch" and game.chef_quest in ["available","defeated"]:
			var quest_marker = Models.text3d(node,"!" if game.chef_quest == "available" else "?",Vector3(0,3,0),Color("ffe183"),64)
			quest_marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			quest_marker.no_depth_test = true
			quest_marker.pixel_size = 0.025
			node.set_meta("quest_marker",quest_marker)
	gate(game,Vector3(-3,0,-6.5),"gate","STAIRS / LOBBY",Color("7edace"))
	gate(game,Vector3(3,0,-6.5),"elevator","KEYCARD ELEVATOR",Color("b5afd9"))
	var title = Models.text3d(root,"B1 / GARAGE REFUGE",Vector3(0,0.07,3.2),Color("d8c496"),32)
	title.rotation_degrees.x = -90

static func gate(game, pos: Vector3, role: String, title: String, color: Color):
	var node = Node3D.new()
	game.dynamic.add_child(node)
	node.position = pos
	if role == "wormhole":
		for radius in [0.8,1.0]:
			var ring = Models.ring(node,radius,color)
			ring.position.y = 1.25
			ring.rotation.x = PI/2
			ring.scale.z = 1.35
		Models.ring(node,1.1,color)
	else:
		for side in [-1,1]: Models.box(node,Vector3(side*0.8,1.3,0),Vector3(0.24,2.6,0.5),Color("78938f"))
		Models.box(node,Vector3(0,2.5,0),Vector3(1.8,0.22,0.5),color,true)
		Models.box(node,Vector3(0,1.2,0),Vector3(1.3,2.2,0.04),Color("264e61"))
		Models.ring(node,1.1,color)
	var label = Models.text3d(node,title+" [E]",Vector3(0,3.1,0),color,30)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.pixel_size = 0.019
	game.interactables.append({"node":node,"role":role})
