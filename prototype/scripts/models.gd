extends RefCounted
## Original procedural placeholder geometry; attachments are actual meshes.

static func material(color: Color, glow: bool = false) -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.85
	if color.a < 1.0:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if glow:
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return m

static func box(parent: Node3D, pos: Vector3, size: Vector3, color: Color, glow: bool = false) -> MeshInstance3D:
	var node = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.material_override = material(color, glow)
	parent.add_child(node)
	node.position = pos
	return node

static func sphere(parent: Node3D, pos: Vector3, size: Vector3, color: Color, glow: bool = false) -> MeshInstance3D:
	var node = MeshInstance3D.new()
	var mesh = SphereMesh.new()
	mesh.radial_segments = 10
	mesh.rings = 5
	mesh.radius = 0.5
	mesh.height = 1.0
	node.mesh = mesh
	node.material_override = material(color, glow)
	parent.add_child(node)
	node.position = pos
	node.scale = size
	return node

static func cylinder(parent: Node3D, pos: Vector3, radius: float, height: float, color: Color, glow: bool = false) -> MeshInstance3D:
	var node = MeshInstance3D.new()
	var mesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 12
	node.mesh = mesh
	node.material_override = material(color, glow)
	parent.add_child(node)
	node.position = pos
	return node

static func ring(parent: Node3D, radius: float, color: Color) -> MeshInstance3D:
	var node = MeshInstance3D.new()
	var mesh = TorusMesh.new()
	mesh.inner_radius = radius - 0.035
	mesh.outer_radius = radius + 0.035
	mesh.rings = 32
	mesh.ring_segments = 6
	node.mesh = mesh
	node.material_override = material(color, true)
	parent.add_child(node)
	node.position.y = 0.06
	return node

static func text3d(parent: Node3D, caption: String, pos: Vector3, color: Color, font_size: int = 40, is_billboard: bool = true) -> Label3D:
	var label = Label3D.new()
	label.text = caption
	label.font_size = font_size
	label.pixel_size = 0.009
	label.modulate = color
	label.outline_size = 6
	label.outline_modulate = Color(0.04, 0.07, 0.10, 0.95)
	if is_billboard:
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.no_depth_test = true
		label.render_priority = 10
	label.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	parent.add_child(label)
	label.position = pos
	return label

static func pet() -> Node3D:
	var root = Node3D.new()
	root.name = "PetModel"
	var fur = Color("c39568")
	var pale = Color("e2c69f")
	var dark = Color("433630")
	sphere(root, Vector3(0, 0.76, 0.02), Vector3(0.83, 0.76, 1.35), fur)
	sphere(root, Vector3(0, 1.03, -0.67), Vector3(0.79, 0.72, 0.7), fur)
	sphere(root, Vector3(0, 0.88, -0.96), Vector3(0.53, 0.27, 0.22), pale)
	box(root, Vector3(0, 0.97, -1.09), Vector3(0.12, 0.09, 0.06), Color("c97d8a"))
	for side in [-1, 1]:
		var ear = cylinder(root, Vector3(side * 0.26, 1.41, -0.63), 0.18, 0.42, fur)
		(ear.mesh as CylinderMesh).top_radius = 0.015
		box(root, Vector3(side * 0.22, 1.1, -0.975), Vector3(0.15, 0.12, 0.05), Color("b8ffd0"), true)
		box(root, Vector3(side * 0.22, 1.1, -1.005), Vector3(0.04, 0.12, 0.025), dark)
		for z in [-0.44, 0.48]:
			var leg = Node3D.new()
			root.add_child(leg)
			leg.name = "Leg%d" % root.get_child_count()
			leg.position = Vector3(side * 0.29, 0.58, z)
			box(leg, Vector3(0, -0.2, 0), Vector3(0.22, 0.43, 0.24), fur)
			sphere(leg, Vector3(0, -0.44, -0.06), Vector3(0.26, 0.2, 0.36), pale)
		for z in [-0.2, 0.12, 0.42]:
			box(root, Vector3(side * 0.403, 0.87, z), Vector3(0.022, 0.23, 0.10), dark)
	var tail = Node3D.new()
	root.add_child(tail)
	tail.name = "Tail"
	tail.position = Vector3(0, 0.84, 0.58)
	var tip = cylinder(tail, Vector3(0, 0.17, 0.4), 0.09, 0.85, fur)
	tip.rotation.x = 1.1
	sphere(tail, Vector3(0, 0.39, 0.76), Vector3(0.19, 0.35, 0.19), dark)
	var gear = Node3D.new()
	gear.name = "Gear"
	root.add_child(gear)
	return root

static func equip(pet_root: Node3D, worn: Dictionary) -> void:
	var equipment = worn.duplicate()
	for slot in ["head","barding"]:
		if equipment[slot].get("affinity","") in ["Draconic","Visceral"]: equipment[slot] = {"model":-1}
	var gear = pet_root.get_node("Gear")
	for child in gear.get_children():
		gear.remove_child(child)
		child.queue_free()
	for slot in ["head","barding"]:
		if worn[slot].get("affinity","") in ["Draconic","Visceral"]: draconic_part(gear,worn[slot])
	var olive = Color("68745b")
	var metal = Color("758990")
	var amber = Color("e4ae51")
	var teal = Color("68ffe0")
	if equipment.head.get("unique_id","") == "chefbot_hat":
		chef_hat(gear,Vector3(0,1.3,-0.68))
	elif equipment.head.model == 2:
		# Clear pressure dome keeps the pet face visible inside its survey helmet.
		var dome = sphere(gear,Vector3(0,1.1,-0.78),Vector3(1.14,1.08,1.1),Color(0.35,0.8,0.9,0.24))
		dome.material_override.cull_mode = BaseMaterial3D.CULL_DISABLED
		cylinder(gear,Vector3(0,0.76,-0.7),0.49,0.12,Color("c8d6dc"))
		for side in [-1,1]:
			box(gear,Vector3(side*0.49,1.05,-0.65),Vector3(0.17,0.33,0.32),Color("d1dadb"))
			box(gear,Vector3(side*0.5,1.25,-0.65),Vector3(0.19,0.08,0.2),teal,true)
	elif equipment.head.model >= 0:
		box(gear,Vector3(0,1.32,-0.68),Vector3(0.66,0.16,0.55),metal if equipment.head.model == 1 else olive)
		if equipment.head.model == 1: box(gear,Vector3(0,1.13,-1.02),Vector3(0.67,0.14,0.10),teal,true)
		else: cylinder(gear,Vector3(0.32,1.50,-0.55),0.035,0.45,amber)
	if equipment.neck.model >= 0:
		box(gear,Vector3(0,0.92,-0.49),Vector3(0.85,0.12,0.14),Color("bda06a"))
		match equipment.neck.model:
			0: sphere(gear,Vector3(0,0.72,-0.77),Vector3(0.22,0.30,0.16),teal)
			1: sphere(gear,Vector3(0,0.72,-0.77),Vector3(0.22,0.30,0.16),Color("9da0ff"))
			2:
				var relay = box(gear,Vector3(0,0.72,-0.82),Vector3(0.24,0.24,0.12),amber,true)
				relay.rotation.z = PI/4
			3:
				box(gear,Vector3(0,0.66,-0.8),Vector3(0.14,0.38,0.12),metal)
				for y in [0.56,0.68,0.8]: box(gear,Vector3(0,y,-0.88),Vector3(0.16,0.04,0.05),Color("87baff"),true)
	var armor: int = equipment.barding.model
	if armor in [0,1]:
		box(gear,Vector3(0,1.08,0.07),Vector3(0.94,0.18,0.90),olive if armor == 0 else metal)
		for side in [-1,1]:
			box(gear,Vector3(side*0.47,0.82,0.05),Vector3(0.13,0.40 if armor == 0 else 0.57,0.82),Color("414e5e"))
	elif armor in [2,3]:
		# Open ribbed bracing / fine lattice mesh: fur remains visible through gaps.
		for side in [-1,1]:
			for z in range(4 if armor == 2 else 8):
				var rib = box(gear,Vector3(side*0.48,0.86,-0.4+z*(0.27 if armor == 2 else 0.13)),Vector3(0.045,0.45,0.035),Color("83a6ac") if armor == 2 else Color("adae8c"))
				rib.rotation.x = 0.3 if z%2 == 0 else -0.3
			for y in [0.68,0.88,1.08]: box(gear,Vector3(side*0.48,y,0.04),Vector3(0.045,0.035,1.0),metal)
		for z in [-0.35,0,0.35]: box(gear,Vector3(0,1.12,z),Vector3(0.94,0.035,0.05),metal)
		if armor == 3:
			for x in [-0.36,-0.18,0,0.18,0.36]: box(gear,Vector3(x,1.12,0.04),Vector3(0.025,0.025,0.94),Color("adae8c"))
	elif armor in [4,5]:
		var color = Color("354e65") if armor == 4 else Color("826548")
		box(gear,Vector3(0,1.075,0.07),Vector3(0.85,0.1,0.93),color)
		for side in [-1,1]:
			box(gear,Vector3(side*0.44,0.86,0.04),Vector3(0.06,0.32,0.9),color)
			for z in [-0.29,0.04,0.37]:
				if armor == 5: box(gear,Vector3(side*0.48,0.86,z),Vector3(0.12,0.25,0.24),Color("ab885e"))
				box(gear,Vector3(side*0.52,0.97,z),Vector3(0.07,0.07,0.07),metal)
	if equipment.harness.model >= 0:
		box(gear,Vector3(0,0.87,0.43),Vector3(1.03,0.31,0.16),Color("3e4845"))
		for side in [-1,1]: box(gear,Vector3(side*0.56,0.86,0.43),Vector3(0.18,0.24,0.3),amber if equipment.harness.model == 0 else teal)
	if equipment.matrix.model == 0:
		box(gear,Vector3(0,1.35,0.3),Vector3(0.44,0.34,0.45),Color("bd975b"))
		box(gear,Vector3(0,1.54,0.3),Vector3(0.30,0.05,0.28),teal,true)
	elif equipment.matrix.model == 1:
		cylinder(gear,Vector3(0,1.40,0.25),0.24,0.55,Color("31485b"))
		var colors = {"Empty":Color("394a50"),"Capacitor":teal,"Relay":Color("f78cd9"),"Ground":amber}
		for i in range(3): cylinder(gear,Vector3(0,1.24+i*0.17,0.25),0.29,0.055,colors[equipment.matrix.sockets[i]],true)
	var weapons = preload("res://scripts/loot.gd").equipped_weapons(equipment)
	for item in weapons:
		var mount = Node3D.new()
		mount.name = "WeaponLeft" if is_same(item,equipment.left) else "WeaponRight"
		gear.add_child(mount)
		var side = -1 if is_same(item,equipment.left) else 1
		var color: Color = preload("res://scripts/loot.gd").TYPES[item.type]
		if item.get("affinity","") in ["Draconic","Visceral"]:
			draconic_part(mount,item,side)
		elif item.get("attack","") == "cleave":
			box(mount,Vector3(0,1.2,-0.7),Vector3(0.18,0.18,1.8),metal)
			box(mount,Vector3(0,1.2,-1.45),Vector3(1.8,0.18,0.6),color,true)
		elif item.hands == 2:
			for flank in [-1,1]:
				box(mount,Vector3(flank*0.65,1.15,-0.24),Vector3(0.42,0.43,1.48),Color("435567"))
				box(mount,Vector3(flank*0.65,1.15,-1.0),Vector3(0.33,0.33,0.09),color,true)
				if item.model == 3:
					for y in [1.02,1.28]: box(mount,Vector3(flank*0.65,y,-1.04),Vector3(0.16,0.16,0.10),amber,true)
		elif item.model == 1:
			var blade = box(mount,Vector3(side*0.67,0.69,-0.83),Vector3(0.10,0.22,1.05),color,true)
			blade.rotation.y = side*-0.2
			box(mount,Vector3(side*0.55,0.69,-0.25),Vector3(0.32,0.17,0.22),metal)
		else:
			box(mount,Vector3(side*0.61,0.85,-0.48),Vector3(0.24,0.27,0.96),metal)
			for z in [-0.84,-0.65,-0.46]: box(mount,Vector3(side*0.61,0.85,z),Vector3(0.28,0.3,0.06),color,true)
	var mode: String = equipment.locomotion.get("mode","paws")
	for child in pet_root.get_children():
		if str(child.name).begins_with("Leg"): child.visible = mode in ["paws","wings","greaves"]
	var loco = Node3D.new()
	loco.name = "Locomotion"
	gear.add_child(loco)
	if equipment.locomotion.get("affinity","") in ["Draconic","Visceral"]:
		draconic_part(loco,equipment.locomotion)
	elif mode == "paws" and equipment.locomotion.model >= 0:
		for x in [-0.3,0.3]:
			for z in [-0.50,0.42]: box(loco,Vector3(x,0.14,z),Vector3(0.3,0.16,0.36),metal)
	elif mode == "treads":
		for side in [-1,1]:
			box(loco,Vector3(side*0.67,0.24,0.04),Vector3(0.39,0.42,1.55),Color("25343a"))
			for z in [-0.47,-0.1,0.27,0.60]: sphere(loco,Vector3(side*0.88,0.24,z),Vector3(0.08,0.29,0.29),metal)
	elif mode == "spider":
		for side in [-1,1]:
			for z in [-0.52,0.05,0.58]:
				var leg = Node3D.new()
				loco.add_child(leg)
				leg.position = Vector3(side*0.35,0.53,z)
				var upper = box(leg,Vector3(side*0.42,-0.02,0),Vector3(0.9,0.12,0.13),metal)
				upper.rotation.z = side*0.25
				var lower = box(leg,Vector3(side*0.85,-0.22,0),Vector3(0.11,0.5,0.12),olive)
				lower.rotation.z = -side*0.2
	elif mode == "hover":
		box(loco,Vector3(0,0.18,0.08),Vector3(1.14,0.18,1.47),Color("3d4d62"))
		for x in [-0.42,0.42]:
			for z in [-0.45,0.55]: cylinder(loco,Vector3(x,0.02,z),0.22,0.16,teal,true)

static func animate_locomotion(pet_root: Node3D, phase: float, moving: bool):
	var loco = pet_root.get_node_or_null("Gear/Locomotion")
	if loco == null: return
	for i in range(loco.get_child_count()):
		var child = loco.get_child(i)
		if str(child.name).begins_with("Wing"):
			child.rotation.z = sin(phase*0.55)*0.15*(1 if child.name == "WingRight" else -1) if moving else 0
		elif child.get_child_count() == 2: child.rotation.z = sin(phase+i*PI*0.7)*0.20 if moving else 0

static func enemy(boss: bool) -> Node3D:
	var root = Node3D.new()
	var hull = Color("83764f") if not boss else Color("976050")
	for side in [-1, 1]:
		box(root, Vector3(side * 0.44, 0.25, 0), Vector3(0.25, 0.4, 1.05), Color("252e32"))
		for z in [-0.32, 0, 0.32]:
			sphere(root, Vector3(side * 0.56, 0.23, z), Vector3(0.12, 0.27, 0.27), Color("536166"))
	box(root, Vector3(0, 0.53, 0), Vector3(0.83, 0.45, 0.8), hull)
	box(root, Vector3(0, 0.86, -0.15), Vector3(0.62, 0.24, 0.45), Color("313c44"))
	box(root, Vector3(0, 0.88, -0.39), Vector3(0.42, 0.09, 0.04), Color("ff796a"), true)
	box(root, Vector3(0.28, 0.95, 0.1), Vector3(0.04, 0.7, 0.04), Color("a8b2a3"))
	if boss:
		for x in [-0.23, 0.23]:
			cylinder(root, Vector3(x, 1.17, 0.12), 0.13, 0.65, Color("a85774"))
		root.scale = Vector3.ONE * 1.45
	return root

static func chef_hat(parent: Node3D, pos: Vector3, size: float = 1.0):
	var hat = Node3D.new()
	parent.add_child(hat)
	hat.position = pos
	hat.scale = Vector3.ONE*size
	cylinder(hat,Vector3(0,0.12,0),0.34,0.24,Color("e5e4d8"))
	cylinder(hat,Vector3(0,0.29,0),0.3,0.27,Color("fbf6df"))
	for x in [-0.24,0,0.24]: sphere(hat,Vector3(x,0.48,0),Vector3(0.42,0.4,0.5),Color("fff9e8"))
	box(hat,Vector3(0,0.15,-0.34),Vector3(0.3,0.06,0.03),Color("e5b958"))
	return hat

static func sentry(type_name: String) -> Node3D:
	if type_name == "obesecat":
		var cat = pet()
		cat.scale = Vector3(2.8,2.2,2.6)
		box(cat,Vector3(0,1.2,0.15),Vector3(0.55,0.3,0.65),Color("f2ba59"),true)
		return cat
	var body = enemy(type_name in ["warden","chef"])
	if type_name == "chef": chef_hat(body,Vector3(0,1.5,0),1.6)
	elif type_name == "laser":
		box(body,Vector3(0,1.05,-0.55),Vector3(0.18,0.18,1.0),Color("8ac4c8"))
		box(body,Vector3(0,1.05,-1.1),Vector3(0.2,0.2,0.1),Color("ffe37a"),true)
	elif type_name == "rocket":
		for x in [-0.28,0.28]: cylinder(body,Vector3(x,1.2,0),0.22,0.85,Color("a77b52"))
	elif type_name == "blade":
		for x in [-0.5,0.5]: box(body,Vector3(x,0.8,-0.5),Vector3(0.09,0.18,1.15),Color("e898ef"),true)
	return body

static func spike(parent: Node3D, pos: Vector3, radius: float, height: float, color: Color) -> MeshInstance3D:
	var node = MeshInstance3D.new()
	var mesh = CylinderMesh.new()
	mesh.top_radius = 0
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 6
	node.mesh = mesh
	node.material_override = material(color)
	node.position = pos
	parent.add_child(node)
	return node

static func membrane(parent: Node3D, points: PackedVector3Array, color: Color):
	var mesh = ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(1,points.size()-1):
		for v in [points[0],points[i],points[i+1]]: mesh.surface_add_vertex(v)
	mesh.surface_end()
	var node = MeshInstance3D.new()
	node.mesh = mesh
	node.material_override = material(color)
	node.material_override.cull_mode = BaseMaterial3D.CULL_DISABLED
	parent.add_child(node)

static func draconic_part(parent: Node3D, item: Dictionary, side: int = 1):
	var bone = Color("e9d6af")
	var steel = Color("858696")
	var scale_color = Color("744355")
	var dark = Color("24232f")
	var element: Color = preload("res://scripts/loot.gd").TYPES[item.get("type","heat")]
	match item.get("visual",""):
		"full_helm":
			box(parent,Vector3(0,1.15,-0.76),Vector3(0.82,0.66,0.64),steel)
			box(parent,Vector3(0,1.19,-1.09),Vector3(0.63,0.065,0.02),dark)
			box(parent,Vector3(0,1.05,-1.10),Vector3(0.06,0.4,0.02),dark)
			spike(parent,Vector3(0,1.58,-0.75),0.16,0.3,bone)
		"frill":
			for flank in [-1,1]:
				membrane(parent,PackedVector3Array([Vector3(flank*0.3,1,-0.4),Vector3(flank*1.1,0.8,-0.4),Vector3(flank*1.15,1.5,-0.4),Vector3(flank*0.6,1.85,-0.4),Vector3(flank*0.25,1.45,-0.4)]),scale_color)
				for i in range(4): spike(parent,Vector3(flank*(0.45+i*0.16),1.6-i*0.13,-0.42),0.045,0.45,bone).rotation.z = -flank*0.65
		"horns":
			for flank in [-1,1]:
				for i in range(8):
					var a = i*0.48
					sphere(parent,Vector3(flank*(0.46+sin(a)*0.29),1.5+cos(a)*0.29,-0.72),Vector3.ONE*(0.24-i*0.019),bone)
		"breast_plate":
			box(parent,Vector3(0,0.91,-0.37),Vector3(1.0,0.6,0.19),steel)
			for flank in [-1,1]:
				sphere(parent,Vector3(flank*0.5,1.02,-0.22),Vector3(0.4,0.38,0.55),steel)
				box(parent,Vector3(flank*0.47,0.85,0.14),Vector3(0.1,0.45,0.9),steel)
			box(parent,Vector3(0,1.12,0.1),Vector3(0.9,0.12,0.9),steel)
		"scale_coat":
			for z in range(5):
				for x in range(5):
					var tile = sphere(parent,Vector3((x-2)*0.21,1.10-abs(x-2)*0.12,-0.4+z*0.23),Vector3(0.29,0.12,0.34),scale_color.lightened(0.08*((x+z)%2)))
					tile.rotation.x = 0.25
		"spines":
			for z in range(5):
				spike(parent,Vector3(0,1.3,-0.4+z*0.25),0.14,0.65,bone).rotation.x = 0.35
				for flank in [-1,1]: spike(parent,Vector3(flank*0.48,1.05,-0.4+z*0.25),0.1,0.4,scale_color).rotation.z = -flank*0.8
		"claws":
			box(parent,Vector3(side*0.48,0.42,-0.48),Vector3(0.42,0.23,0.34),scale_color)
			for i in range(3): spike(parent,Vector3(side*0.48+(i-1)*0.13,0.38,-0.82),0.08,0.65,bone).rotation.x = -PI/2
		"fangs":
			for flank in [-1,1]:
				spike(parent,Vector3(flank*0.38,0.65,-1.0),0.16,1.1,bone).rotation.x = -0.45
				box(parent,Vector3(flank*0.4,1.0,-0.75),Vector3(0.25,0.22,0.3),scale_color)
		"breath":
			for flank in [-1,1]: sphere(parent,Vector3(flank*0.42,0.95,-0.65),Vector3(0.35,0.4,0.45),scale_color)
			sphere(parent,Vector3(0,0.83,-1.15),Vector3(0.35,0.22,0.23),element)
			for flank in [-1,1]: spike(parent,Vector3(flank*0.15,0.8,-1.16),0.035,0.22,bone).rotation.x = PI
		"wand":
			var wand = cylinder(parent,Vector3(side*0.63,0.88,-0.74),0.055,1.2,Color("4e3244"))
			wand.rotation.x = PI/2
			sphere(parent,Vector3(side*0.63,0.88,-1.36),Vector3.ONE*0.19,element)
		"wings":
			for flank in [-1,1]:
				var wing = Node3D.new()
				wing.name = "WingRight" if flank == 1 else "WingLeft"
				parent.add_child(wing)
				membrane(wing,PackedVector3Array([Vector3(flank*0.35,1,0),Vector3(flank*1.5,1.7,-0.5),Vector3(flank*1.85,1.1,0.5),Vector3(flank*1.25,0.9,0.3),Vector3(flank*0.9,0.85,0.8)]),scale_color)
				var spar = box(wing,Vector3(flank*0.9,1.4,-0.24),Vector3(1.3,0.08,0.08),bone)
				spar.rotation.z = flank*0.5
				spike(wing,Vector3(flank*1.5,1.75,-0.5),0.07,0.35,bone)
		"wyrm_legs","greaves":
			for x in [-0.36,0.36]:
				for z in [-0.48,0.43]:
					var leg = Node3D.new()
					parent.add_child(leg)
					leg.position = Vector3(x,0.3,z)
					box(leg,Vector3.ZERO,Vector3(0.23,0.43,0.26),steel if item.visual == "greaves" else scale_color)
					box(leg,Vector3(0,-0.23,-0.12),Vector3(0.3,0.12,0.5),steel if item.visual == "greaves" else bone)

		"ocular":
			sphere(parent,Vector3(0,1.39,-0.89),Vector3(0.42,0.3,0.3),Color("dec6b1"))
			sphere(parent,Vector3(0,1.42,-1.04),Vector3(0.2,0.22,0.06),Color("94c888"))
			sphere(parent,Vector3(0,1.42,-1.08),Vector3(0.055,0.18,0.035),dark)
		"cranium":
			cylinder(parent,Vector3(0,1.31,-0.7),0.38,0.12,bone)
			for x in [-0.16,0.16]:
				for z in [-0.92,-0.7,-0.48]: sphere(parent,Vector3(x,1.47,z),Vector3(0.31,0.29,0.3),Color("bf7a8a"))
		"tentacle","tail":
			var tail: bool = item.visual == "tail"
			for i in range(12):
				var pos = Vector3(sin(i*0.32)*(0.7 if tail else 0.32)+(0 if tail else side*0.6),0.7+cos(i*0.25)*0.2,(0.45+i*0.16) if tail else (-0.35-i*0.12))
				sphere(parent,pos,Vector3.ONE*(0.28-i*0.015),Color("915168"))
				if i%2 == 0: sphere(parent,pos+Vector3(0,-0.1,0),Vector3(0.11,0.06,0.11),Color("d9a1a0"))
		"acid_spray":
			for flank in [-1,1]: sphere(parent,Vector3(flank*0.32,0.87,-0.6),Vector3(0.42,0.43,0.5),Color("83976b"))
			sphere(parent,Vector3(0,0.84,-1.09),Vector3(0.35,0.23,0.27),element)
		"quills":
			box(parent,Vector3(side*0.55,0.85,-0.4),Vector3(0.3,0.23,0.48),Color("915168"))
			for i in range(5): spike(parent,Vector3(side*0.55+(i-2)*0.07,0.89,-0.69),0.035,0.7,bone).rotation.x = -PI/2
