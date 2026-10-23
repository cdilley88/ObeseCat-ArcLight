extends RefCounted
## B1 / Garage Refuge — Survivor Town Hub
## Underground parking garage sanctuary with vendor workshops, central fire pit,
## architectural glass entrance to Floor 01, and service elevator waypoint.

const Models = preload("res://scripts/models.gd")
const Loot = preload("res://scripts/loot.gd")

# Physical collision footprints for A* navigation avoidance (obstacles & counters)
const COVERS = [
	Rect2(-9.2, -9.6, 3.4, 1.8),  # Weapons back-counter
	Rect2(5.8, -9.6, 3.4, 1.8),   # Armor back-counter
	Rect2(-12.2, 3.0, 1.8, 2.0),  # Signal Broker back-fixture
	Rect2(10.2, 3.4, 2.0, 2.0),   # Dispatch back-fixture
	Rect2(-0.8, -0.3, 1.6, 1.6),  # Central campfire hearth
	Rect2(-6.5, -1.5, 1.0, 1.0),  # Pillar NW
	Rect2(5.5, -1.5, 1.0, 1.0),   # Pillar NE
	Rect2(-6.5, 5.5, 1.0, 1.0),   # Pillar SW
	Rect2(5.5, 5.5, 1.0, 1.0),    # Pillar SE
	Rect2(11.2, -2.5, 1.2, 3.0),  # Service Elevator wall shaft
	Rect2(-2.5, -9.8, 5.0, 1.0)   # North door wall arch
]

# Town NPC contacts (Dev/debug moved to System menu; cosmetics reserved)
const CONTACTS = [
	["weapons", "WEAPONS", Vector3(-7.5, 0, -6.5), Color("e2b572")],
	["armor", "ARMOR", Vector3(7.5, 0, -6.5), Color("7abac9")],
	["broker", "SIGNAL BROKER", Vector3(-8.8, 0, 4.0), Color("ae8be2")],
	["dispatch", "DISPATCH", Vector3(7.6, 0, 4.4), Color("d9cd97")]
]

static func build(game):
	var root: Node3D = game.arena
	
	# Poured asphalt / dark concrete parking slab (25.5 x 20.0)
	Models.box(root, Vector3(0, -0.25, 0), Vector3(25.5, 0.5, 20.0), Color("222b2f"))
	
	# Paved floor tiles with central drive aisle
	for x in range(-12, 13):
		for z in range(-9, 10):
			var is_drive_lane = abs(x) <= 2 or z in [0, 1]
			var tile_color = Color("384347") if is_drive_lane else Color("293337")
			Models.box(root, Vector3(x, 0, z), Vector3(0.96, 0.04, 0.96), tile_color)
	
	# Perimeter concrete retaining walls
	# North wall (tall back wall behind entrance)
	Models.box(root, Vector3(0, 1.8, -9.9), Vector3(25.5, 3.6, 0.4), Color("3d4b50"))
	game.obstacle(Vector3(0, 1.8, -9.9), Vector3(25.5, 4.0, 0.5))
	
	# South wall (lower curb wall for camera clearance)
	Models.box(root, Vector3(0, 0.7, 9.7), Vector3(25.5, 1.4, 0.4), Color("364448"))
	game.obstacle(Vector3(0, 0.7, 9.7), Vector3(25.5, 2.5, 0.5))
	
	# West wall
	Models.box(root, Vector3(-12.5, 1.5, 0), Vector3(0.4, 3.0, 19.8), Color("3a474c"))
	game.obstacle(Vector3(-12.5, 1.5, 0), Vector3(0.5, 3.5, 19.8))
	
	# East wall
	Models.box(root, Vector3(12.5, 1.5, 0), Vector3(0.4, 3.0, 19.8), Color("3a474c"))
	game.obstacle(Vector3(12.5, 1.5, 0), Vector3(0.5, 3.5, 19.8))
	
	# Concrete curbs with safety yellow trim
	for x in [-12.1, 12.1]:
		Models.box(root, Vector3(x, 0.12, 0), Vector3(0.35, 0.24, 19.4), Color("b8a755"))
	Models.box(root, Vector3(0, 0.12, -9.5), Vector3(24.6, 0.24, 0.35), Color("b8a755"))
	
	# Overhead industrial ventilation duct along upper North wall
	Models.box(root, Vector3(0, 3.3, -9.4), Vector3(24.8, 0.45, 0.65), Color("4e5d63"))
	for dx in [-10, -5, 5, 10]:
		Models.box(root, Vector3(dx, 3.3, -9.4), Vector3(0.18, 0.55, 0.75), Color("6f8087"))
	
	# 4 Structural Concrete Columns with OSHA hazard stripes
	for pos in [Vector3(-6, 0, -1), Vector3(6, 0, -1), Vector3(-6, 0, 6), Vector3(6, 0, 6)]:
		# Yellow hazard base
		Models.box(root, pos + Vector3(0, 0.55, 0), Vector3(1.0, 1.1, 1.0), Color("cfb954"))
		for strip in [0.25, 0.65]:
			Models.box(root, pos + Vector3(0, strip, 0), Vector3(1.04, 0.14, 1.04), Color("232b2e"))
		# Raw concrete pillar
		Models.box(root, pos + Vector3(0, 2.2, 0), Vector3(0.85, 2.4, 0.85), Color("637276"))
		# Capital cap
		Models.box(root, pos + Vector3(0, 3.35, 0), Vector3(1.3, 0.25, 1.3), Color("4a585c"))
		game.obstacle(pos + Vector3(0, 1.5, 0), Vector3(1.0, 3.5, 1.0))
	
	# Painted parking stall bay lines on floor
	for bay_x in [-10.5, -4.5, 4.5, 10.5]:
		for z_line in [-8.5, -4.5]:
			Models.box(root, Vector3(bay_x, 0.04, z_line), Vector3(0.12, 0.03, 3.6), Color("d5c56c"))
	for bay_x in [-11.0, -6.5, 6.5, 11.0]:
		for z_line in [3.0, 7.0]:
			Models.box(root, Vector3(bay_x, 0.04, z_line), Vector3(0.12, 0.03, 3.6), Color("d5c56c"))
	
	# Central Fire Pit & Survivor Camp
	build_fire_pit(root, game)
	
	# Dedicated Vendor Stalls & Workshops
	build_vendor_bays(root, game)
	
	# Glass Double Door Entrance to Floor 01 (Lobby)
	build_glass_entrance(root, game)
	
	# Heavy Industrial Service Elevator (Waypoint System)
	build_service_elevator(root, game)
	
	# Floor title sign (decals flat on floor)
	var title = Models.text3d(root, "B1 / GARAGE REFUGE", Vector3(0, 0.06, 3.8), Color("8ea4ad"), 34, false)
	title.rotation_degrees.x = -90

static func build_fire_pit(root: Node3D, game):
	var pos = Vector3(0, 0, 0.5)
	
	# Concrete / stone circular hearth
	Models.cylinder(root, pos + Vector3(0, 0.22, 0), 0.9, 0.44, Color("455255"))
	# Inner charred burning bed
	Models.cylinder(root, pos + Vector3(0, 0.28, 0), 0.7, 0.35, Color("1c1917"))
	
	# Glowing blazing fire core
	var flame = Models.sphere(root, pos + Vector3(0, 0.85, 0), Vector3(0.65, 0.95, 0.65), Color("ff8e36"), true)
	flame.material_override.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	# Surrounding glowing embers ring
	Models.ring(root, 1.25, Color("e09c48"))
	
	# Painted refuge safety circle on asphalt
	Models.ring(root, 2.5, Color("4f636a"))
	
	# Warm cozy omni light
	var warmth = OmniLight3D.new()
	warmth.position = pos + Vector3(0, 1.6, 0)
	warmth.light_color = Color("ffba6e")
	warmth.light_energy = 1.7
	warmth.omni_range = 9.5
	root.add_child(warmth)
	
	# Central hearth obstacle
	game.obstacle(pos + Vector3(0, 0.6, 0), Vector3(1.6, 1.4, 1.6))
	
	# Casual seating around fire: wooden salvage crates & oil drums
	Models.box(root, pos + Vector3(-1.8, 0.25, 0.2), Vector3(0.55, 0.5, 0.55), Color("54463c"))
	Models.box(root, pos + Vector3(1.8, 0.25, 0.5), Vector3(0.6, 0.5, 0.55), Color("435154"))
	Models.cylinder(root, pos + Vector3(-0.9, 0.42, 2.0), 0.35, 0.84, Color("6e4742"))
	Models.cylinder(root, pos + Vector3(1.2, 0.42, 1.9), 0.32, 0.84, Color("3e5257"))

static func build_vendor_bays(root: Node3D, game):
	# ---------------- Bay 01: Weapons Workshop (North-West) ----------------
	var w_pos = Vector3(-7.5, 0, -6.5)
	# Workbench counter against back wall
	Models.box(root, Vector3(-7.5, 0.55, -8.7), Vector3(3.2, 1.1, 0.85), Color("3e4c52"))
	Models.box(root, Vector3(-7.5, 1.12, -8.7), Vector3(3.3, 0.08, 0.95), Color("607278"))
	game.obstacle(Vector3(-7.5, 0.6, -8.7), Vector3(3.3, 1.5, 1.0))
	
	# Gunsmith back rack & tool wall
	Models.box(root, Vector3(-7.5, 1.5, -9.4), Vector3(3.0, 2.0, 0.3), Color("2c373b"))
	Models.box(root, Vector3(-8.3, 1.6, -9.2), Vector3(0.8, 0.15, 0.15), Color("d8ab60"), true)
	Models.box(root, Vector3(-6.7, 1.3, -9.2), Vector3(1.0, 0.15, 0.15), Color("c98d48"), true)
	# Ammo crate stack beside bench
	Models.box(root, Vector3(-9.5, 0.35, -8.5), Vector3(0.7, 0.7, 0.7), Color("4a5940"))
	
	# ---------------- Bay 02: Armor & Salvage Workshop (North-East) ----------------
	var a_pos = Vector3(7.5, 0, -6.5)
	# Heavy armory counter against back wall
	Models.box(root, Vector3(7.5, 0.55, -8.7), Vector3(3.2, 1.1, 0.85), Color("39474c"))
	Models.box(root, Vector3(7.5, 1.12, -8.7), Vector3(3.3, 0.08, 0.95), Color("5a6d73"))
	game.obstacle(Vector3(7.5, 0.6, -8.7), Vector3(3.3, 1.5, 1.0))
	
	# Armor plating rack & chassis frame
	Models.box(root, Vector3(7.5, 1.5, -9.4), Vector3(3.0, 2.0, 0.3), Color("283438"))
	Models.box(root, Vector3(7.5, 1.5, -9.2), Vector3(1.2, 1.4, 0.15), Color("6eb0c2"), true)
	# Hydraulic press / power conduit fixture
	Models.cylinder(root, Vector3(9.5, 0.9, -8.5), 0.3, 1.8, Color("4a6369"))
	
	# ---------------- Bay 03: Signal Broker Outpost (South-West) ----------------
	var b_pos = Vector3(-8.8, 0, 4.0)
	# Makeshift communications desk against west wall
	Models.box(root, Vector3(-11.3, 0.55, 4.0), Vector3(1.2, 1.1, 2.4), Color("323e42"))
	Models.box(root, Vector3(-11.3, 1.12, 4.0), Vector3(1.3, 0.08, 2.5), Color("49595f"))
	game.obstacle(Vector3(-11.3, 0.6, 4.0), Vector3(1.3, 1.5, 2.4))
	
	# Dual CRT monitors with glowing purple/green displays
	Models.box(root, Vector3(-11.0, 1.35, 3.6), Vector3(0.55, 0.45, 0.45), Color("1a2326"))
	Models.box(root, Vector3(-10.7, 1.35, 3.6), Vector3(0.04, 0.38, 0.38), Color("b07ce6"), true)
	var mon2 = Models.box(root, Vector3(-11.0, 1.3, 4.4), Vector3(0.5, 0.4, 0.4), Color("1a2326"))
	mon2.rotation.y = -0.2
	Models.box(root, Vector3(-10.7, 1.3, 4.4), Vector3(0.04, 0.34, 0.34), Color("5de4c2"), true)
	# Tall radio receiver wire
	Models.cylinder(root, Vector3(-11.5, 1.6, 2.6), 0.03, 2.4, Color("6b7c82"))
	
	# ---------------- Bay 04: Tactical Dispatch Station (South-East) ----------------
	var d_pos = Vector3(7.6, 0, 4.4)
	# Tactical mission desk against east wall
	Models.box(root, Vector3(11.2, 0.55, 4.4), Vector3(1.2, 1.1, 2.4), Color("354145"))
	Models.box(root, Vector3(11.2, 1.12, 4.4), Vector3(1.3, 0.08, 2.5), Color("4d5e63"))
	game.obstacle(Vector3(11.2, 0.6, 4.4), Vector3(1.3, 1.5, 2.4))
	
	# Illuminated map table / holographic console
	Models.box(root, Vector3(10.9, 1.2, 4.4), Vector3(0.6, 0.06, 1.6), Color("e1d18c"), true)
	# Tactical antenna & status transponder
	Models.cylinder(root, Vector3(11.4, 1.5, 3.0), 0.03, 2.2, Color("768990"))
	Models.sphere(root, Vector3(11.4, 2.6, 3.0), Vector3(0.12, 0.12, 0.12), Color("ffd369"), true)
	
	# Spawn NPC Cats in their dedicated bays
	for contact in CONTACTS:
		var node = Node3D.new()
		game.dynamic.add_child(node)
		node.position = contact[2]
		var pet = Models.pet()
		node.add_child(pet)
		# Face towards central refuge fire pit
		pet.rotation.y = atan2(-contact[2].x, -contact[2].z)
		
		var kit = {}
		for slot in Loot.SLOTS: kit[slot] = Loot.empty_item(slot)
		kit.head = Loot.make_item("head", 1, game.rng, false)
		kit.harness = Loot.make_item("harness", 0, game.rng, false)
		Models.equip(pet, kit)
		
		# Floor interaction ring
		Models.ring(node, 0.85, contact[3])
		
		# High-resolution billboarded tag
		var label = Models.text3d(node, contact[1] + " [E]", Vector3(0, 2.1, 0), contact[3], 28)
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.no_depth_test = true
		label.pixel_size = 0.019
		
		game.interactables.append({"node": node, "role": contact[0]})
		
		# Dispatch quest marker
		if contact[0] == "dispatch" and game.chef_quest in ["available", "defeated"]:
			var quest_marker = Models.text3d(node, "!" if game.chef_quest == "available" else "?", Vector3(0, 3.1, 0), Color("ffe183"), 64)
			quest_marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			quest_marker.no_depth_test = true
			quest_marker.pixel_size = 0.025
			node.set_meta("quest_marker", quest_marker)

static func build_glass_entrance(root: Node3D, game):
	# Architectural entrance fixture sits on North wall
	var wall_pos = Vector3(0, 0, -9.4)
	
	# Left & right frame jambs
	Models.box(root, wall_pos + Vector3(-1.75, 1.5, 0), Vector3(0.35, 3.0, 0.5), Color("253034"))
	Models.box(root, wall_pos + Vector3(1.75, 1.5, 0), Vector3(0.35, 3.0, 0.5), Color("253034"))
	# Header beam
	Models.box(root, wall_pos + Vector3(0, 3.0, 0), Vector3(3.85, 0.4, 0.55), Color("1f272a"))
	
	# Dual Glass Doors (cyan-tinted luminous glass)
	Models.box(root, wall_pos + Vector3(-0.75, 1.35, 0), Vector3(1.4, 2.5, 0.06), Color(0.24, 0.68, 0.74, 0.85), true)
	Models.box(root, wall_pos + Vector3(0.75, 1.35, 0), Vector3(1.4, 2.5, 0.06), Color(0.24, 0.68, 0.74, 0.85), true)
	
	# Stainless steel vertical push bars
	Models.box(root, wall_pos + Vector3(-0.15, 1.25, 0.08), Vector3(0.05, 1.1, 0.06), Color("d5e7eb"))
	Models.box(root, wall_pos + Vector3(0.15, 1.25, 0.08), Vector3(0.05, 1.1, 0.06), Color("d5e7eb"))
	
	# Overhead illuminated bulkhead lightbox sign: "STAIRS TO FLOOR 01 / LOBBY"
	Models.box(root, wall_pos + Vector3(0, 3.35, 0.05), Vector3(3.6, 0.55, 0.22), Color("101a1d"))
	Models.box(root, wall_pos + Vector3(0, 3.35, 0.17), Vector3(3.4, 0.42, 0.04), Color("62e4d8"), true)
	
	# Concrete approach steps with yellow caution chevron
	Models.box(root, wall_pos + Vector3(0, 0.06, 0.7), Vector3(3.5, 0.12, 0.8), Color("3a484c"))
	for i in range(4):
		Models.box(root, wall_pos + Vector3(-1.2 + i * 0.8, 0.13, 0.7), Vector3(0.14, 0.03, 0.75), Color("d8c257"))
	
	# Interactive target node in front of doors (walkable!)
	var node = Node3D.new()
	game.dynamic.add_child(node)
	node.position = Vector3(0, 0, -7.5)
	
	# Floor interaction ring
	Models.ring(node, 1.35, Color("7edace"))
	
	# High-visibility billboarded label
	var label = Models.text3d(node, "STAIRS / FLOOR 01 [E]", Vector3(0, 3.9, -1.2), Color("7edace"), 30)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.pixel_size = 0.019
	
	game.interactables.append({"node": node, "role": "gate"})

static func build_service_elevator(root: Node3D, game):
	# Elevator shaft fixture against East wall
	var wall_pos = Vector3(11.8, 0, -1.0)
	
	# Heavy structural steel elevator shaft framing
	Models.box(root, wall_pos + Vector3(0.3, 1.6, 0), Vector3(0.6, 3.2, 3.4), Color("293438"))
	# Left and right elevator door jambs
	Models.box(root, wall_pos + Vector3(-0.3, 1.5, -1.4), Vector3(0.4, 3.0, 0.35), Color("39474c"))
	Models.box(root, wall_pos + Vector3(-0.3, 1.5, 1.4), Vector3(0.4, 3.0, 0.35), Color("39474c"))
	# Elevator header beam
	Models.box(root, wall_pos + Vector3(-0.3, 3.0, 0), Vector3(0.45, 0.4, 3.15), Color("222b2e"))
	
	# Corrugated sliding steel elevator doors with yellow & charcoal caution stripes
	Models.box(root, wall_pos + Vector3(-0.45, 1.35, 0), Vector3(0.08, 2.5, 2.4), Color("445257"))
	for i in range(5):
		Models.box(root, wall_pos + Vector3(-0.5, 0.4 + i * 0.45, 0), Vector3(0.04, 0.16, 2.35), Color("d5bb4d"))
	
	# Elevator call button console on jamb with indicator lights
	Models.box(root, wall_pos + Vector3(-0.4, 1.25, 1.65), Vector3(0.12, 0.45, 0.3), Color("162024"))
	Models.sphere(root, wall_pos + Vector3(-0.46, 1.35, 1.65), Vector3(0.08, 0.08, 0.08), Color("5eff94"), true)
	Models.sphere(root, wall_pos + Vector3(-0.46, 1.15, 1.65), Vector3(0.08, 0.08, 0.08), Color("ff6352"), true)
	
	# Digital floor indicator display over doors
	Models.box(root, wall_pos + Vector3(-0.4, 2.85, 0), Vector3(0.1, 0.35, 2.2), Color("121b1e"))
	Models.box(root, wall_pos + Vector3(-0.45, 2.85, 0), Vector3(0.04, 0.22, 2.0), Color("81ffb2"), true)
	
	# Yellow loading-zone hatch box on asphalt floor in front of doors
	for z_line in range(-4, 5):
		Models.box(root, wall_pos + Vector3(-1.8, 0.05, z_line * 0.25), Vector3(1.2, 0.03, 0.08), Color("d4ba4c"))
	
	# Interactive target node in front of elevator (walkable!)
	var node = Node3D.new()
	game.dynamic.add_child(node)
	node.position = Vector3(9.5, 0, -1.0)
	
	# Floor interaction ring
	Models.ring(node, 1.35, Color("b5afd9"))
	
	# Billboarded label
	var label = Models.text3d(node, "SERVICE ELEVATOR [E]", Vector3(0, 3.6, 0), Color("b5afd9"), 30)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.pixel_size = 0.019
	
	game.interactables.append({"node": node, "role": "elevator"})

static func gate(game, pos: Vector3, role: String, title: String, color: Color):
	var node = Node3D.new()
	game.dynamic.add_child(node)
	node.position = pos
	if role == "wormhole":
		for radius in [0.8, 1.0]:
			var ring = Models.ring(node, radius, color)
			ring.position.y = 1.25
			ring.rotation.x = PI / 2
			ring.scale.z = 1.35
		Models.ring(node, 1.1, color)
	else:
		for side in [-1, 1]: Models.box(node, Vector3(side * 0.8, 1.3, 0), Vector3(0.24, 2.6, 0.5), Color("78938f"))
		Models.box(node, Vector3(0, 2.5, 0), Vector3(1.8, 0.22, 0.5), color, true)
		Models.box(node, Vector3(0, 1.2, 0), Vector3(1.3, 2.2, 0.04), Color("264e61"))
		Models.ring(node, 1.1, color)
	var label = Models.text3d(node, title + " [E]", Vector3(0, 3.1, 0), color, 30)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.pixel_size = 0.019
	game.interactables.append({"node": node, "role": role})
