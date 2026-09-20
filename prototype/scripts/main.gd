extends Node

const Chests = preload("res://scripts/chests.gd")
var chests: Array = []
const Tower = preload("res://scripts/tower.gd")
const Hub = preload("res://scripts/hub.gd")
const Economy = preload("res://scripts/economy.gd")
const Models = preload("res://scripts/models.gd")
const Loot = preload("res://scripts/loot.gd")
const Hud = preload("res://scripts/hud.gd")
const Progression = preload("res://scripts/progression.gd")
const Backpack = preload("res://scripts/backpack.gd")
const BOUNDS = Rect2(-10, -8, 20, 16)
const COVERS = [Rect2(-3.8, -0.8, 2.2, 1.6), Rect2(2.0, 2.3, 2.0, 1.6)]
const SPAWN = Vector3(-6, 0, 5)
const FAULT = Vector3(3.2, 0, -3.4)

var viewport: SubViewport
var world: Node3D
var arena: Node3D
var dynamic: Node3D
var camera: Camera3D
var player: CharacterBody3D
var pet: Node3D
var player_ring: MeshInstance3D
var fault_ring: MeshInstance3D
var fault_echo: Node3D
var hud
var astar = AStarGrid2D.new()
var rng = RandomNumberGenerator.new()
const WorldRandom = preload("res://scripts/world_random.gd")
var run_seed: int = WorldRandom.fresh()
var arena_open_counts: Dictionary = {}
var area = "hub"
var keycards: Array = []
var visited: Array = []
var zone_states: Dictionary = {}
var elevator_access = false
var act_complete = false
var silicon: int = 80
var run_number: int = 0
var shops: Dictionary = {}
var buyback: Array = []
var hub_ground: Array = []
var interactables: Array = []
var target_contact: Dictionary = {}
var menu_open = ""
var inventory: Array = []
var equipment: Dictionary = {}
var enemies: Array = []
var drops: Array = []
var effects: Array = []
var path: Array[Vector3] = []
var target_enemy: Dictionary = {}
var target_drop: Dictionary = {}
var hp: float = 100
var mana: float = 50
var progression = Progression.new()
var character_open = false
var empowered = false
var attack_cooldown: float = 0
var attack_windup: float = -1
var attack_victim: Dictionary = {}
var attack_weapon: Dictionary = {}
var weapon_turn = 0
var pending_hits: Array = []
var player_status = {"burn": 0.0, "burn_damage": 0.0, "tick": 0.0, "slow": 0.0, "stop": 0.0,"weaken":0.0}
var salvage_count = 0
var charge: float = 0
var circuit_cooldown: float = 0
var started = false
var paused = false
var inventory_open = false
var won = false
var effects_enabled = true
var sound_enabled = true
var message = ""
var message_time: float = 0
var clock: float = 0
var fault_time: float = 0
var fault_fired = false
var step_time: float = 0
var repath_timer: float = 0
var heal_charges: int = 2 # Legacy fixture only; player controls now use potions.
var potions = {"life":6,"mana":4}
var potion_cooldowns = {"life":0.0,"mana":0.0}
var wormhole: Dictionary = {}
var chef_quest: String = "locked"
var audio: AudioStreamPlayer
var tones: Dictionary = {}

func _ready():
	build_viewport()
	build_audio()
	hud = Hud.new(self)
	add_child(hud)
	restart(false)
	started = false
	hud.update_hud()

func build_viewport():
	var holder = SubViewportContainer.new()
	holder.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	holder.stretch = true
	holder.stretch_shrink = 2
	holder.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(holder)
	viewport = SubViewport.new()
	viewport.size = Vector2i(640, 400)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.handle_input_locally = false
	holder.add_child(viewport)
	world = Node3D.new()
	viewport.add_child(world)
	var env = WorldEnvironment.new()
	var resource = Environment.new()
	resource.background_mode = Environment.BG_COLOR
	resource.background_color = Color("101b26")
	resource.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	resource.ambient_light_color = Color("a2c4c5")
	resource.ambient_light_energy = 0.6
	env.environment = resource
	world.add_child(env)
	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52, -30, 0)
	sun.light_color = Color("eed8ae")
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	world.add_child(sun)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 24.0
	camera.position = Vector3(19, 24, 19)
	world.add_child(camera)
	camera.look_at(Vector3.ZERO)
	camera.current = true
	arena = Node3D.new()
	world.add_child(arena)
	dynamic = Node3D.new()
	world.add_child(dynamic)

func obstacle(center: Vector3, size: Vector3):
	var body = StaticBody3D.new()
	arena.add_child(body)
	body.position = center
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)

func build_room():
	Models.box(arena, Vector3(0, -0.28, 0), Vector3(20.5, 0.5, 16.5), Color("283238"))
	for x in range(-10, 10):
		for z in range(-8, 8):
			var shade = 0.01 * posmod(x * 7 + z * 13, 5)
			Models.box(arena, Vector3(x + 0.5, 0, z + 0.5), Vector3(0.965, 0.06, 0.965), Color(0.19 + shade, 0.24 + shade, 0.25 + shade))
	for x in range(-10, 10, 2):
		Models.box(arena, Vector3(x + 1, 1.15, -8.1), Vector3(1.95, 2.3, 0.3), Color("39434a"))
		Models.box(arena, Vector3(x + 1, 1.75, -7.9), Vector3(1.1, 0.12, 0.06), Color("8cd2bc"), true)
	for z in range(-8, 8, 2):
		Models.box(arena, Vector3(-10.1, 1.0, z + 1), Vector3(0.3, 2.0, 1.95), Color("3b4649"))
	Models.box(arena, Vector3(10.1, 0.15, 0), Vector3(0.25, 0.3, 16.2), Color("76847d"))
	Models.box(arena, Vector3(0, 0.15, 8.1), Vector3(20.2, 0.3, 0.25), Color("76847d"))
	obstacle(Vector3(-10.4, 1, 0), Vector3(0.6, 3, 17))
	obstacle(Vector3(10.4, 1, 0), Vector3(0.6, 3, 17))
	obstacle(Vector3(0, 1, -8.4), Vector3(21, 3, 0.6))
	obstacle(Vector3(0, 1, 8.4), Vector3(21, 3, 0.6))
	for rect in COVERS:
		var center = Vector3(rect.get_center().x, 0.65, rect.get_center().y)
		var size = Vector3(rect.size.x, 1.3, rect.size.y)
		Models.box(arena, center, size, Color("53625a"))
		Models.box(arena, center + Vector3(0, 0.72, 0), Vector3(size.x + 0.1, 0.14, size.z + 0.1), Color("8b977c"))
		obstacle(center, size)
		for x in range(5):
			var stripe = Models.box(arena, center + Vector3(-0.8 + x * 0.36, 0, size.z / 2 + 0.01), Vector3(0.16, 0.6, 0.025), Color("d4aa53"))
			stripe.rotation.z = -0.35
	# Oversized experimental coils and a dead-serious command terminal.
	for x in [-7.5, 7.5]:
		Models.cylinder(arena, Vector3(x, 0.65, -6.6), 0.72, 1.3, Color("5f6d66"))
		for y in [1.4, 1.7, 2.0]:
			Models.cylinder(arena, Vector3(x, y, -6.6), 0.59, 0.12, Color("7cb2af"))
		Models.sphere(arena, Vector3(x, 2.25, -6.6), Vector3(0.7, 0.5, 0.7), Color("a6d4c9"))
	Models.box(arena, Vector3(-8.8, 0.6, 3.8), Vector3(0.8, 1.2, 1.4), Color("4d645b"))
	var terminal = Models.box(arena, Vector3(-8.7, 1.35, 3.8), Vector3(0.85, 0.16, 0.8), Color("7fffc5"), true)
	terminal.rotation.z = -0.3
	var sign = Models.text3d(arena, "CIVIL DEFENSE / TRIAL 01", Vector3(0, 2.0, -7.85), Color("e1c988"), 34)
	sign.no_depth_test = false
	var floor_sign = Models.text3d(arena, "AUTHORIZED PETS ONLY", Vector3(-5.5, 0.07, 5.6), Color("aaa47b"), 24)
	floor_sign.rotation_degrees.x = -90
	for i in range(12):
		Models.box(arena, Vector3(-8.2 + i * 0.42, 0.06, 6.8), Vector3(0.22, 0.04, 0.4), Color("c2a257"))
	build_fault()

func build_fault():
	var fault_root = Node3D.new()
	arena.add_child(fault_root)
	fault_root.position = FAULT
	fault_ring = Models.ring(fault_root, 2.0, Color("985b9b"))
	Models.cylinder(fault_root, Vector3(0, 0.12, 0), 0.65, 0.24, Color("353b51"))
	fault_echo = Node3D.new()
	fault_root.add_child(fault_echo)
	for i in range(3):
		Models.box(fault_echo, Vector3(0, 0.65 + i * 0.5, 0), Vector3(0.9 - i * 0.17, 0.18, 0.9), Color("bd79bc"), true)
	Models.text3d(arena, "SIGNAL FAULT", FAULT + Vector3(0, 2.5, 0), Color("ed95d8"), 24).billboard = BaseMaterial3D.BILLBOARD_ENABLED

func area_bounds() -> Rect2:
	return Tower.bounds(area) if Tower.ZONES.has(area) else BOUNDS

func area_covers() -> Array:
	if area == "debug_arena": return []
	return Tower.covers(area,run_seed,run_number) if Tower.ZONES.has(area) else (Hub.COVERS if area == "hub" else COVERS)

func build_navigation():
	var bounds = area_bounds()
	var cells = Vector2i(bounds.size*2)
	astar.region = Rect2i(Vector2i.ZERO,cells)
	astar.cell_size = Vector2(0.5,0.5)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar.update()
	for x in range(cells.x):
		for y in range(cells.y):
			var p = bounds.position+Vector2(0.25+x*0.5,0.25+y*0.5)
			var solid = not bounds.grow(-0.6).has_point(p)
			for rect in area_covers():
				if rect.grow(0.5).has_point(p): solid = true
			astar.set_point_solid(Vector2i(x,y),solid)

func grid_cell(pos: Vector3) -> Vector2i:
	var bounds = area_bounds()
	return Vector2i(clampi(int((pos.x-bounds.position.x)*2),0,int(bounds.size.x*2)-1),clampi(int((pos.z-bounds.position.y)*2),0,int(bounds.size.y*2)-1))

func make_path(from: Vector3, to: Vector3) -> Array[Vector3]:
	var result: Array[Vector3] = []
	var begin_cell = grid_cell(from)
	var end_cell = grid_cell(to)
	if astar.is_point_solid(begin_cell) or astar.is_point_solid(end_cell): return result
	var ids = astar.get_id_path(begin_cell, end_cell)
	for i in range(1, ids.size()):
		result.append(Vector3(area_bounds().position.x+0.25+ids[i].x*0.5,0,area_bounds().position.y+0.25+ids[i].y*0.5))
	if result.is_empty() and begin_cell == end_cell: result.append(to)
	return result

func restart(new_seed: bool, keep_character: bool = false, destination: String = "hub"):
	var previous_area = area
	var previous_life = hp
	var previous_mana = mana
	var previous_repairs = heal_charges
	if keep_character: save_zone()
	if new_seed: run_seed = WorldRandom.fresh(run_seed)
	if not keep_character:
		rng.seed = WorldRandom.derive(run_seed,0,"global","combat")
		arena_open_counts.clear()
	if keep_character and area == "hub":
		hub_ground = []
		for drop in drops: hub_ground.append({"item":drop.item,"pos":drop.node.position})
	if not keep_character:
		hub_ground.clear()
		zone_states.clear()
		keycards.clear()
		visited.clear()
		act_complete = false
		chef_quest = "locked"
		potions = {"life":6,"mana":4}
		potion_cooldowns = {"life":0.0,"mana":0.0}
		wormhole.clear()
	elevator_access = false
	area = destination
	menu_open = ""
	interactables.clear()
	chests.clear()
	target_contact = {}
	for child in arena.get_children():
		arena.remove_child(child)
		child.queue_free()
	for child in dynamic.get_children():
		dynamic.remove_child(child)
		child.queue_free()
	enemies.clear()
	drops.clear()
	effects.clear()
	pending_hits.clear()
	attack_weapon = {}
	weapon_turn = 0
	player_status = {"burn": 0.0, "burn_damage": 0.0, "tick": 0.0, "slow": 0.0, "stop": 0.0,"weaken":0.0}
	salvage_count = 0
	path.clear()
	target_enemy = {}
	target_drop = {}
	attack_victim = {}
	if not keep_character:
		silicon = 80
		run_number = 0
		buyback.clear()
		shops = Economy.stock(run_seed,1)
		progression = Progression.new()
		inventory.clear()
		equipment.clear()
		for slot in Loot.SLOTS:
			equipment[slot] = Loot.empty_item(slot)
		# Minimal accepted starter: one white Cybernetic melee weapon.
		var starter = Loot.make_item("weapon",1,rng,false)
		inventory.append(starter)
		equipment.left = starter
		Backpack.arrange(inventory,equipment)
	hp = current_stats().max_life
	mana = current_stats().max_mana
	character_open = false
	empowered = false
	charge = 0
	circuit_cooldown = 0
	attack_cooldown = 0
	attack_windup = -1
	fault_time = 0
	fault_fired = false
	clock = 0
	heal_charges = 2
	won = false
	paused = false
	inventory_open = false
	started = true
	player = CharacterBody3D.new()
	player.name = "Player"
	dynamic.add_child(player)
	player.position = Tower.spawn(area) if Tower.ZONES.has(area) else (Vector3(0,0,4) if area == "hub" else SPAWN)
	var collision = CollisionShape3D.new()
	var shape = CapsuleShape3D.new()
	shape.radius = 0.45
	shape.height = 1.1
	collision.shape = shape
	collision.position.y = 0.6
	player.add_child(collision)
	pet = Models.pet()
	player.add_child(pet)
	pet.rotation.y = -2.2
	Models.equip(pet, equipment)
	player_ring = Models.ring(player, 0.78, Color("71c5b3"))
	if area == "hub":
		Hub.build(self)
		for saved in hub_ground: spawn_drop(saved.pos,saved.item)
		toast("Garage Refuge",2)
	elif area == "debug_arena":
		preload("res://scripts/debug_arena.gd").build(self)
		player.position = Vector3(0,0,4)
		toast("TEST RANGE / talk to the range operator",4)
	elif Tower.ZONES.has(area):
		Tower.build(self,area)
		if not visited.has(area): visited.append(area)
		restore_zone()
		toast(Tower.ZONES[area].name,2)
		if area == "dining" and chef_quest == "locked":
			chef_quest = "available"
			toast("DISPATCH / New quest available: Defeat ChefBot. Return to the Garage or use a Wormhole.",9)
	else:
		build_room()
		spawn_enemy(Vector3(-5, 0, -0.9), false, 0)
		spawn_enemy(Vector3(-0.2, 0, -4.4), false, 1)
		spawn_enemy(Vector3(6, 0, 2.5), false, 2)
		spawn_enemy(Vector3(5.8, 0, -4.8), true, 3)
		toast("Clear the chamber. Silicon is recovered automatically. T returns after clear or defeat.",7)
	sync_wormhole()
	build_navigation()
	if keep_character and area != "hub" and previous_area != "hub":
		hp = minf(previous_life,current_stats().max_life)
		mana = minf(previous_mana,current_stats().max_mana)
		heal_charges = previous_repairs
	if is_instance_valid(hud):
		hud.selection = 3
		hud.refresh_inventory()
		hud.update_hud()

func spawn_enemy(pos: Vector3, boss: bool, index: int, type_id: String = ""):
	if type_id == "": type_id = "supervisor" if boss else "security"
	var definition: Dictionary = preload("res://scripts/encounters.gd").TYPES[type_id]
	var node = Node3D.new()
	dynamic.add_child(node)
	node.position = pos
	var model = Models.sentry(definition.model)
	var threat: String = "gravity" if boss else (Loot.ELEMENTS[index % 6] if Tower.ZONES.has(area) else ["radiation","physical","corruption"][index % 3])
	Models.box(model,Vector3(0,1.05,-0.3),Vector3(0.25,0.15,0.25),Loot.TYPES[threat],true)
	node.add_child(model)
	var warning = Models.ring(node, 3.1 if boss else 1.7, Color("ff8b60"))
	warning.visible = false
	var marker = Models.text3d(node, "WARDEN / GRAVUUM / 150" if boss else "SENTRY / " + threat.to_upper() + " / 52", Vector3(0, 2.2 if boss else 1.5, 0), Color("ffb599"), 30)
	marker.pixel_size = 0.015
	marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	var enemy = {"node": node, "model": model, "hp": 150.0 if boss else 52.0, "max_hp": 150.0 if boss else 52.0, "boss": boss, "warning": warning, "label": marker, "state": "idle", "timer": 0.4, "index": index, "route": [], "route_time": 0.0, "attack_number": 0, "radius": 1.7}
	enemy.merge({"burn":0.0,"burn_damage":0.0,"tick":0.0,"slow":0.0,"stop":0.0,"corruption_hits":0,"weaken":0.0,"spread":false,"dot_type":"radiation","affinity":"Cybernetic","resists":{"radiation":10.0 if index == 0 else 0.0,"gravity":15.0 if boss else 0.0,"corruption":20.0 if boss else 0.0},"dodge":0.15 if boss else 0.08})
	enemy.merge({"attack_damage":12.0 if boss else 11.0,"xp_reward":75 if boss else 25,"silicon_reward":24 if boss else 6,"loot_level":1,"loot_cap":1,"title":"WARDEN / GRAV" if boss else "SENTRY"})
	if Tower.ZONES.has(area):
		enemy.merge(Tower.profile(area,boss),true)
		enemy["element"] = threat
		enemy.model.scale *= 1.0 + Tower.ZONES[area].level*0.018
		enemy.label.text = "%s / %d" % [enemy.title,enemy.hp]
	if definition.has("weapon"):
		enemy["element"] = definition.element
		enemy["home"] = pos
		enemy["patrol_leg"] = 0
		enemy["aim"] = pos
		if not boss: enemy.title = type_id.replace("_"," ").to_upper()
		enemy.label.text = "%s / %d" % [enemy.title,enemy.hp]
	enemy["type_id"] = type_id
	enemy["affinity"] = definition.affinity
	enemy["behavior"] = definition.behavior
	enemies.append(enemy)

func begin():
	started = true
	toast("Garage Refuge",2)
	hud.update_hud()

func current_stats() -> Dictionary:
	var stats = progression.derive(Loot.stats(equipment))
	if player_status.get("weaken",0) > 0:
		stats.damage *= 0.8
		stats.armor *= 0.8
	return stats

func save_zone():
	if not Tower.ZONES.has(area): return
	var snapshot = {"enemies":[],"drops":[],"salvage":salvage_count,"rng":rng.state,"chests":chests.duplicate(true)}
	for enemy in enemies: snapshot.enemies.append({"hp":enemy.hp,"pos":enemy.node.position})
	for drop in drops: snapshot.drops.append({"item":drop.item,"pos":drop.node.position})
	zone_states[area] = snapshot

func restore_zone():
	if not zone_states.has(area): return
	var snapshot: Dictionary = zone_states[area]
	for chest in snapshot.get("chests",[]): Chests.build(self,chest.duplicate(true))
	for i in range(mini(enemies.size(),snapshot.enemies.size())):
		var enemy: Dictionary = enemies[i]
		enemy.hp = snapshot.enemies[i].hp
		enemy.node.position = snapshot.enemies[i].pos
		enemy.label.text = "%s / %d" % [enemy.title,enemy.hp]
		if enemy.hp <= 0:
			enemy.label.text = ""
			enemy.model.rotation.z = PI/2
			enemy.model.position.y = 0.2
	for saved in snapshot.drops: spawn_drop(saved.pos,saved.item)
	salvage_count = snapshot.salvage
	rng.state = snapshot.rng
	won = living_enemies() == 0

func in_danger() -> bool:
	for enemy in enemies:
		if enemy.hp > 0 and enemy.node.position.distance_to(player.position) < 6: return true
	return false

func repeat_chamber():
	if area == "run" and (won or hp <= 0): restart(false,true,"hub")
	elif Tower.ZONES.has(area) and hp <= 0: restart(false,true,"hub")
	else: toast("Use stairs or an authorized elevator to return. T recovers to the garage after defeat.")

func shop_tier() -> int:
	var tier = 1
	for id in keycards:
		if Tower.ZONES.has(id): tier = maxi(tier,Tower.ZONES[id].level)
	return tier

func start_run():
	if area != "hub": return
	if run_number == 0: run_number = 1
	shops = Economy.stock(run_seed+run_number*917,shop_tier())
	restart(false,true,"lobby")

func new_sortie() -> bool:
	if area != "hub": return false
	zone_states.clear()
	wormhole.clear()
	sync_wormhole()
	run_number += 1
	shops = Economy.stock(run_seed+run_number*917,shop_tier())
	toast("Tower encounters repopulated. Floor loot cleared. Keycards and your character retained.",7)
	return true

func linked_destination(destination: String) -> bool:
	if area == "hub": return destination == "lobby"
	if not Tower.ZONES.has(area): return false
	var data: Dictionary = Tower.ZONES[area]
	if destination == data.prev or destination == data.get("side",""): return true
	return destination == data.get("next","") and keycards.has(area)

func travel_zone(destination: String, by_elevator: bool = false) -> bool:
	if destination != "hub" and not Tower.ZONES.has(destination): return false
	if hp <= 0 or in_danger():
		toast("Security is too close. Clear space before traveling.")
		return false
	if by_elevator:
		if not elevator_access or menu_open != "elevator" or (destination != "hub" and not keycards.has(destination)): return false
	elif not linked_destination(destination):
		toast("Access denied. Defeat this floor's supervisor and recover its keycard.",5)
		return false
	var old_area = area
	var arrival = Vector3.ZERO
	# Enter at the matching return/forward/branch doorway, not a fresh spawn on every backtrack.
	if Tower.ZONES.has(destination):
		if by_elevator: arrival = Tower.spawn(destination)
		elif old_area == Tower.ZONES[destination].get("next",""): arrival = Vector3(0,0,Tower.bounds(destination).position.y+4)
		elif old_area == Tower.ZONES[destination].get("side",""): arrival = Vector3(Tower.bounds(destination).end.x-4,0,3)
		else: arrival = Tower.spawn(destination)
	if old_area == "hub" and run_number == 0: run_number = 1
	restart(false,true,destination)
	if destination != "hub": player.position = arrival
	return true

func open_tower_map(at_elevator: bool = false):
	if not started: return
	if at_elevator and in_danger():
		toast("Security is too close to use the elevator.")
		return
	if menu_open in ["tower","elevator"] and not at_elevator:
		close_contact()
		return
	elevator_access = at_elevator
	menu_open = "elevator" if at_elevator else "tower"
	inventory_open = false
	character_open = false
	paused = true
	path.clear()
	target_contact = {}
	hud.hide_item_card()
	hud.hub_menu.open(menu_open)

func close_contact():
	elevator_access = false
	menu_open = ""
	paused = false
	hud.hub_menu.hide()

func interact(contact: Dictionary):
	if contact.is_empty() or not interactables.has(contact) or hp <= 0: return
	if player.position.distance_to(contact.node.position) > 2.2: return
	path.clear()
	target_contact = {}
	match contact.role:
		"arena_exit": restart(false,true,"hub")
		"arena_control":
			menu_open = "arena_control"
			paused = true
			hud.hub_menu.open(menu_open)
		"chest": Chests.open(self,contact)
		"wormhole": use_wormhole()
		"gate": start_run()
		"travel": travel_zone(contact.destination)
		"elevator": open_tower_map(true)
		"ceo_terminal":
			if keycards.has("obesecat"):
				act_complete = true
				toast("ACT I COMPLETE / ObeseCat defeated. ArcLight aftermath and Act II are not built yet.",60)
			else: toast("Defeat ObeseCat to conclude Act I.")
		"return": repeat_chamber()
		_:
			if area != "hub": return
			menu_open = contact.role
			inventory_open = false
			character_open = false
			paused = true
			hud.hide_item_card()
			hud.hub_menu.open(contact.role)

func interact_nearby():
	var best: Dictionary = {}
	var distance = 2.2
	for contact in interactables:
		if contact.role == "chest" and contact.chest.opened: continue
		var d = player.position.distance_to(contact.node.position)
		if d < distance:
			distance = d
			best = contact
	if not best.is_empty(): interact(best)
	elif area != "hub" or not drops.is_empty(): collect_nearby()
	else: toast("Approach a contact or the run gate, then E. You can also click them.")

func trading() -> bool:
	return area == "hub" and menu_open in ["weapons","armor"]

func sell_item(item: Dictionary) -> bool:
	if not trading(): return false
	var index = Backpack.index_of(inventory,item)
	if index < 0 or Backpack.worn(item,equipment): return false
	var amount = Economy.value(item)
	inventory.remove_at(index)
	item.grid_pos = Backpack.NOWHERE
	buyback.append({"item":item,"price":amount})
	silicon += amount
	hud.refresh_inventory()
	toast("Sold " + item.name + " for %d Silicon. Buyback available." % amount)
	return true

func buy_item(item: Dictionary) -> bool:
	if not trading(): return false
	var index = Backpack.index_of(shops[menu_open],item)
	if index < 0: return false
	var amount = Economy.price(item)
	if silicon < amount:
		toast("Not enough Silicon.")
		return false
	if not add_to_backpack(item):
		toast("Make room in your backpack first.")
		return false
	silicon -= amount
	shops[menu_open].remove_at(index)
	hud.refresh_inventory()
	toast("Purchased " + item.name + ".")
	return true

func buy_back(entry: Dictionary) -> bool:
	if not trading(): return false
	var index = Backpack.index_of(buyback,entry)
	if index < 0: return false
	if silicon < entry.price:
		toast("Not enough Silicon for buyback.")
		return false
	if not add_to_backpack(entry.item):
		toast("Make room in your backpack first.")
		return false
	silicon -= entry.price
	buyback.remove_at(index)
	hud.refresh_inventory()
	toast("Recovered " + entry.item.name + ".")
	return true

func debug_apply(values: Dictionary) -> bool:
	if area != "hub" or menu_open != "debug": return false
	progression.level = clampi(int(values.get("level",progression.level)),1,99)
	progression.xp = 0
	progression.points = clampi(int(values.get("points",progression.points)),0,9999)
	for key in Progression.ATTRIBUTES: progression.attributes[key] = clampi(int(values.get(key,progression.attributes[key])),1,999)
	silicon = clampi(int(values.get("silicon",silicon)),0,999999)
	hp = current_stats().max_life
	mana = current_stats().max_mana
	hud.refresh_inventory()
	hud.refresh_character()
	toast("DEV values applied. XP reset; Life/Mana restored.")
	return true

func add_potions(kind: String, amount: int) -> int:
	if not potions.has(kind) or amount <= 0: return 0
	var added = mini(amount,99-potions[kind])
	potions[kind] += added
	return added

func drink_potion(kind: String) -> bool:
	if not started or paused or hp <= 0 or not potions.has(kind): return false
	if potions[kind] <= 0 or potion_cooldowns[kind] > 0: return false
	var stats = current_stats()
	if kind == "life":
		if hp >= stats.max_life: return false
		hp = minf(stats.max_life,hp+maxf(40,stats.max_life*0.4))
	else:
		if mana >= stats.max_mana: return false
		mana = minf(stats.max_mana,mana+maxf(30,stats.max_mana*0.4))
	potions[kind] -= 1
	potion_cooldowns[kind] = 1.0
	tone("equip")
	hud.update_hud()
	return true

func buy_potion(kind: String) -> bool:
	if not trading() or not potions.has(kind) or potions[kind] >= 99 or silicon < 8: return false
	silicon -= 8
	add_potions(kind,1)
	hud.update_hud()
	return true

func debug_action(action: String) -> bool:
	if area != "hub" or menu_open != "debug": return false
	match action:
		"arena":
			restart(false,true,"debug_arena")
			return true
		"potions": potions = {"life":99,"mana":99}
		"visceral_samples":
			for kind in Loot.BASES:
				for base in range(Loot.BASES[kind].size()):
					if Loot.BASES[kind][base].get("affinity","") == "Visceral": spawn_drop(player.position,Loot.make_item(kind,base,rng,false))
			toast("Six Visceral samples placed at your feet.")
		"draconic_samples":
			for kind in Loot.BASES:
				for base in range(Loot.BASES[kind].size()):
					if Loot.BASES[kind][base].get("affinity","") == "Draconic": spawn_drop(player.position,Loot.make_item(kind,base,rng,false))
			toast("13 Draconic samples placed at your feet.")
		"samples":
			for element in Loot.ELEMENTS:
				var item = Loot.make_item("weapon",0,rng,false)
				item.type = element
				item.name = element.capitalize()+" test carbine"
				if not add_to_backpack(item): spawn_drop(player.position,item)
			for tier in range(5):
				var item = Loot.make_item("neck",0,rng,true,1,tier)
				if not add_to_backpack(item): spawn_drop(player.position,item)
			hud.refresh_inventory()
		"unlock": keycards = Tower.FLOOR_ORDER.duplicate()
		"reset_waypoints":
			keycards.clear()
			zone_states.clear()
			act_complete = false
			wormhole.clear()
			sync_wormhole()
		_: return false
	hud.update_hud()
	return true

func sync_wormhole():
	for contact in interactables.duplicate():
		if contact.role == "wormhole":
			interactables.erase(contact)
			contact.node.get_parent().remove_child(contact.node)
			contact.node.queue_free()
	if wormhole.is_empty(): return
	if area == "hub": Hub.gate(self,Vector3(0,0,-3),"wormhole","RETURN / "+Tower.ZONES[wormhole.area].name,Color("b795ff"))
	elif area == wormhole.area: Hub.gate(self,wormhole.pos,"wormhole","WORMHOLE / GARAGE",Color("b795ff"))

func cast_wormhole() -> bool:
	if not started or paused or hp <= 0: return false
	if area == "hub": return use_wormhole()
	if not Tower.ZONES.has(area): return false
	wormhole = {"area":area,"pos":player.position}
	sync_wormhole()
	toast("Wormhole open.",2)
	return true

func use_wormhole() -> bool:
	if not started or paused or hp <= 0 or wormhole.is_empty(): return false
	if area == "hub":
		var destination: String = wormhole.area
		var arrival: Vector3 = wormhole.pos
		restart(false,true,destination)
		player.position = arrival
	elif area == wormhole.area: restart(false,true,"hub")
	else: return false
	return true

func open_system():
	if not started: return
	if menu_open == "system": close_contact(); return
	inventory_open = false
	character_open = false
	elevator_access = false
	menu_open = "system"
	paused = true
	path.clear()
	target_contact = {}
	hud.hide_item_card()
	hud.hub_menu.open("system")

func spend_attribute(attribute: String):
	var before = current_stats()
	if not progression.spend(attribute): return
	var after = current_stats()
	# Preserve missing resource amounts; adding capacity does not refill existing damage.
	if hp > 0: hp = minf(after.max_life, hp + after.max_life - before.max_life)
	mana = minf(after.max_mana, mana + after.max_mana - before.max_mana)
	hud.refresh_character()
	hud.refresh_inventory()
	tone("equip")

func award_xp(amount: int):
	var gained = progression.gain_xp(amount)
	if gained > 0:
		if hp > 0:
			hp = current_stats().max_life
			mana = current_stats().max_mana
		toast("LEVEL %d! +%d stat points. C to allocate.%s" % [progression.level, gained * Progression.POINTS_PER_LEVEL, " Life / Mana restored." if hp > 0 else ""], 8)
		pulse(player.position, Color("eecf77"), 1.5, 0.7)
		tone("equip")
	hud.refresh_character()

func toggle_character():
	if not started: return
	if menu_open != "": close_contact()
	character_open = not character_open
	inventory_open = false
	paused = character_open
	path.clear()
	target_enemy = {}
	target_drop = {}
	hud.refresh_character()
	hud.update_hud()

func toggle_empowered():
	if not started or paused or hp <= 0: return
	if empowered:
		empowered = false
	elif mana >= 10:
		empowered = true
		toast("Empowered strike armed. Next connected attack costs 10 Mana. Q cancels.")
	else: toast("Need 10 Mana. Mana regenerates while the trial runs.")

func living_enemies() -> int:
	var count = 0
	for enemy in enemies:
		if enemy.hp > 0: count += 1
	return count

func toggle_inventory():
	if not started: return
	if menu_open != "": close_contact()
	inventory_open = not inventory_open
	character_open = false
	paused = inventory_open
	path.clear()
	target_enemy = {}
	target_drop = {}
	hud.refresh_inventory()
	hud.update_hud()

func can_equip_item(index: int, slot: String = "") -> bool:
	if index < 0 or index >= inventory.size(): return false
	return Backpack.swap_plan(inventory,equipment,inventory[index],slot).ok

func gear_changed():
	charge = 0
	attack_windup = -1
	attack_victim = {}
	attack_weapon = {}
	var stats = current_stats()
	hp = minf(hp,stats.max_life)
	mana = minf(mana,stats.max_mana)
	Models.equip(pet,equipment)
	hud.refresh_preview()
	hud.hide_item_card()

func equip_item(index: int, slot: String = "") -> bool:
	if index < 0 or index >= inventory.size(): return false
	var item: Dictionary = inventory[index]
	if slot == "" and Backpack.worn(item,equipment): return true
	var plan = Backpack.swap_plan(inventory,equipment,item,slot)
	if not plan.ok:
		toast("Cannot equip here, or displaced parts do not fit in the backpack.",5)
		return false
	for placement in plan.placements: placement.item.grid_pos = placement.pos
	equipment = plan.equipment
	item.grid_pos = Backpack.NOWHERE
	gear_changed()
	tone("equip")
	toast("Equipped: " + item.name,4)
	return true

func remove_equipped(item: Dictionary):
	for slot in Loot.SLOTS:
		if is_same(equipment[slot],item): equipment[slot] = Loot.empty_item(slot)
	gear_changed()

func add_to_backpack(item: Dictionary) -> bool:
	if Backpack.index_of(inventory, item) >= 0: return false
	var pos = Backpack.first_fit(inventory, equipment, item)
	if pos == Backpack.NOWHERE: return false
	item.grid_pos = pos
	inventory.append(item)
	return true

func move_inventory_item(index: int, pos: Vector2i) -> bool:
	if index < 0 or index >= inventory.size(): return false
	var item: Dictionary = inventory[index]
	if not Backpack.can_place(inventory, equipment, item, pos): return false
	if Backpack.worn(item, equipment):
		remove_equipped(item)
	item.grid_pos = pos
	return true

func unequip_item(index: int) -> bool:
	if index < 0 or index >= inventory.size() or not Backpack.worn(inventory[index], equipment): return false
	var pos = Backpack.first_fit(inventory, equipment, inventory[index])
	if pos == Backpack.NOWHERE:
		toast("Backpack full. Make space before unequipping.")
		return false
	return move_inventory_item(index, pos)

func auto_pack():
	if Backpack.arrange(inventory, equipment): toast("Backpack organized.")
	else: toast("Auto-pack could not find a layout. Your items have not moved.")
	hud.refresh_inventory()

func drop_inventory_item(index: int) -> bool:
	if index < 0 or index >= inventory.size(): return false
	var item: Dictionary = inventory[index]
	if Backpack.worn(item, equipment):
		remove_equipped(item)
	inventory.remove_at(index)
	item.grid_pos = Backpack.NOWHERE
	spawn_drop(player.position, item)
	hud.selection = mini(index, inventory.size() - 1)
	toast("Dropped " + item.name + ". It remains on the ground.")
	hud.refresh_inventory()
	return true

func cycle_socket(index: int):
	var sockets: Array = equipment.matrix.sockets
	if sockets.size() != 3: return
	var current = Loot.PARTS.find(sockets[index])
	# One reusable component of each type in this laboratory kit.
	for offset in range(1, 5):
		var next: String = Loot.PARTS[(current + offset) % 4]
		if next == "Empty" or not sockets.has(next):
			sockets[index] = next
			break
	charge = 0
	Models.equip(pet, equipment)
	hud.refresh_preview()
	hud.hide_item_card()
	tone("equip")
	if Loot.circuit_active(equipment.matrix): toast("EMERGENCY RETURN online. Stand still to charge.", 5)

func toggle_fx():
	effects_enabled = not effects_enabled
	hud.update_hud()

func toggle_sound():
	sound_enabled = not sound_enabled
	hud.update_hud()

func toast(text: String, duration: float = 4):
	message = text
	message_time = duration

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		camera.size = clampf(camera.size + (-1.5 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.5), 13.5, 28.5)
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_ENTER:
				if not started: begin()
			KEY_I, KEY_TAB: toggle_inventory()
			KEY_C: toggle_character()
			KEY_Q: toggle_empowered()
			KEY_T: repeat_chamber()
			KEY_V: open_tower_map()
			KEY_F: toggle_fx()
			KEY_M: toggle_sound()
			KEY_ESCAPE:
				if menu_open != "": close_contact()
				elif inventory_open: toggle_inventory()
				elif character_open: toggle_character()
				elif started: open_system()
			KEY_E:
				if started and not paused and hp > 0: interact_nearby()
			KEY_B: cast_wormhole()
			KEY_Z: drink_potion("life")
			KEY_X: drink_potion("mana")
		return
	if not started or paused or hp <= 0: return
	if event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
		var point = ground_point(event.position)
		if point == null: return
		target_enemy = {}
		target_drop = {}
		target_contact = {}
		if event.button_index == MOUSE_BUTTON_LEFT:
			var contact_distance = 55.0
			for contact in interactables:
				if contact.role == "chest" and contact.chest.opened: continue
				var screen = camera.unproject_position(contact.node.position+Vector3(0,0.8,0))*Vector2(get_viewport().get_visible_rect().size)/Vector2(viewport.size)
				if screen.distance_to(event.position) < contact_distance:
					contact_distance = screen.distance_to(event.position)
					target_contact = contact
			var best_distance = 48.0
			for enemy in enemies:
				if enemy.hp <= 0: continue
				var screen = camera.unproject_position(enemy.node.position + Vector3(0, 0.65, 0)) * Vector2(get_viewport().get_visible_rect().size) / Vector2(viewport.size)
				var d = screen.distance_to(event.position)
				if d < best_distance:
					best_distance = d
					target_enemy = enemy
			if target_enemy.is_empty():
				for drop in drops:
					var screen = camera.unproject_position(drop.node.position + Vector3(0, 0.4, 0)) * Vector2(get_viewport().get_visible_rect().size) / Vector2(viewport.size)
					if screen.distance_to(event.position) < 40:
						target_drop = drop
		if not target_contact.is_empty(): point = target_contact.node.position
		if not target_enemy.is_empty(): point = target_enemy.node.position
		if not target_drop.is_empty(): point = target_drop.node.position
		path = make_path(player.position, point)
		repath_timer = 0
		pulse(point, Color("65d4bb"), 0.3, 0.35)

func ground_point(screen: Vector2):
	var local = screen * Vector2(viewport.size) / get_viewport().get_visible_rect().size
	var origin = camera.project_ray_origin(local)
	var direction = camera.project_ray_normal(local)
	return Plane(Vector3.UP, 0).intersects_ray(origin, direction)

func _physics_process(delta):
	if not is_instance_valid(player): return
	if is_instance_valid(hud): hud.update_hud()
	if not started or paused: return
	for kind in potion_cooldowns: potion_cooldowns[kind] = maxf(0,potion_cooldowns[kind]-delta)
	message_time = maxf(0, message_time - delta)
	clock += delta
	if not target_contact.is_empty() and player.position.distance_to(target_contact.node.position) <= 2.0:
		interact(target_contact)
		return
	update_effects(delta)
	if hp <= 0: return
	attack_cooldown = maxf(0, attack_cooldown - delta)
	circuit_cooldown = maxf(0, circuit_cooldown - delta)
	update_statuses(delta)
	if hp <= 0: return
	var stats = current_stats()
	var direction = Vector3.ZERO
	mana = minf(stats.max_mana, mana + stats.mana_regen * delta)
	hp = minf(stats.max_life,hp+stats.life_regen*delta)
	var key_direction = Vector2(float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)), float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W)))
	if key_direction.length() > 0:
		path.clear()
		target_contact = {}
		target_enemy = {}
		target_drop = {}
		direction = Vector3(key_direction.x + key_direction.y, 0, -key_direction.x + key_direction.y).normalized()
	else:
		if not target_enemy.is_empty():
			if target_enemy.hp <= 0:
				target_enemy = {}
				path.clear()
			else:
				var distance = player.position.distance_to(target_enemy.node.position)
				if distance <= weapon_reach(selected_weapon()) and clear_shot(player.position, target_enemy.node.position):
					path.clear()
					request_attack(target_enemy)
				else:
					repath_timer -= delta
					if repath_timer <= 0:
						path = make_path(player.position, target_enemy.node.position)
						repath_timer = 0.35
		if not target_drop.is_empty() and player.position.distance_to(target_drop.node.position) < 1.5:
			pickup(target_drop)
			target_drop = {}
			path.clear()
		while not path.is_empty() and player.position.distance_to(path[0]) < 0.18: path.pop_front()
		if not path.is_empty(): direction = player.position.direction_to(path[0])
	if Input.is_physical_key_pressed(KEY_SPACE):
		var nearest = nearest_enemy(weapon_reach(selected_weapon()))
		if not nearest.is_empty(): request_attack(nearest)
	if attack_windup >= 0:
		attack_windup -= delta
		direction *= 0.15
		if attack_windup < 0: resolve_attack()
	if player_status.stop > 0: direction = Vector3.ZERO
	player.velocity = direction * stats.speed * (0.65 if player_status.slow > 0 else 1.0)
	player.move_and_slide()
	player.position.y = 0
	var moving = player.velocity.length() > 0.15
	if moving:
		pet.rotation.y = lerp_angle(pet.rotation.y, atan2(-direction.x, -direction.z), minf(1, delta * 14))
		charge = 0
		step_time += delta * 9
	elif stats.circuit and circuit_cooldown <= 0:
		charge = minf(1.5, charge + delta)
	else: charge = 0
	var leg_index = 0
	for child in pet.get_children():
		if str(child.name).begins_with("Leg"):
			child.rotation.x = sin(step_time + (0 if leg_index in [0, 3] else PI)) * 0.42 if moving else 0.0
			leg_index += 1
	pet.get_node("Tail").rotation.z = sin(clock * 2) * 0.15
	pet.position.y = absf(sin(step_time)) * 0.035 if moving else sin(clock * 2) * 0.012
	if equipment.locomotion.get("mode", "paws") == "hover": pet.position.y += 0.22 + sin(clock*3)*0.06
	Models.animate_locomotion(pet,step_time,moving)
	player_ring.material_override.albedo_color = Color("cfff9b") if charge >= 1.5 else Color("65b7a7")
	for enemy in enemies:
		if enemy.hp > 0: update_enemy(enemy, delta)
	if area in ["run","archive"]: update_fault(delta)
	for drop in drops:
		drop.gem.rotation.y += delta
		if drop.item.get("tier",0) == 4:
			drop.gem.scale = Vector3.ONE*(1.0+sin(clock*3)*0.15 if effects_enabled else 1.0)
		drop.gem.position.y = 0.4 + sin(clock * 3) * 0.08

func _process(delta):
	for contact in interactables:
		if contact.role == "chest" and contact.node.has_meta("halo"):
			var halo = contact.node.get_meta("halo")
			halo.scale = Vector3.ONE*(1.0+sin(Time.get_ticks_msec()*0.003)*0.07 if effects_enabled and (not contact.chest.opened or contact.chest.get("repeatable",false)) else 1.0)
	if not is_instance_valid(player): return
	var follow = 1.0 if Tower.ZONES.has(area) else clampf(0.1 + (24.0 - camera.size) * 0.075, 0.1, 0.88)
	var focus = Vector3(player.position.x * follow, 0, player.position.z * follow)
	var desired = Vector3(19, 24, 19) + focus
	camera.position = camera.position.lerp(desired, minf(1.0, delta * 5))
	# Preserve the isometric angle while the camera follows, including paused zoom.
	camera.rotation_degrees = Vector3(-41.77, 45, 0)

func nearest_enemy(radius: float) -> Dictionary:
	var nearest: Dictionary = {}
	var best = radius
	for enemy in enemies:
		if enemy.hp <= 0: continue
		var d = player.position.distance_to(enemy.node.position)
		if d < best:
			best = d
			nearest = enemy
	return nearest

func clear_shot(from: Vector3, to: Vector3) -> bool:
	var query = PhysicsRayQueryParameters3D.create(from + Vector3(0, 0.7, 0), to + Vector3(0, 0.7, 0))
	query.exclude = [player.get_rid()]
	return world.get_world_3d().direct_space_state.intersect_ray(query).is_empty()

func selected_weapon() -> Dictionary:
	var weapons = Loot.equipped_weapons(equipment)
	if weapons.is_empty(): return {"name":"Bare strike","damage":4.0,"reach":2.3,"period":0.72,"windup":0.19,"type":"physical","signature":false,"hands":1}
	return weapons[weapon_turn % weapons.size()]

func request_attack(enemy: Dictionary):
	if attack_cooldown > 0 or attack_windup >= 0 or player_status.stop > 0: return
	var weapon = selected_weapon()
	if enemy.hp <= 0 or player.position.distance_to(enemy.node.position) > weapon_reach(weapon): return
	if not clear_shot(player.position,enemy.node.position): return
	attack_weapon = weapon.duplicate(true)
	attack_weapon["mount"] = "WeaponLeft" if is_same(weapon,equipment.left) else "WeaponRight"
	attack_victim = enemy
	var haste = 1.0 + current_stats().attack_speed / 100.0
	attack_windup = weapon.windup / haste
	attack_cooldown = weapon.period / haste
	weapon_turn += 1
	var direction = player.position.direction_to(enemy.node.position)
	pet.rotation.y = atan2(-direction.x,-direction.z)

func resolve_attack():
	if attack_victim.is_empty() or attack_victim.hp <= 0: return
	var weapon = attack_weapon if not attack_weapon.is_empty() else selected_weapon()
	if player_status.stop > 0 or player.position.distance_to(attack_victim.node.position) > weapon_reach(weapon) + 0.3: return
	if not clear_shot(player.position,attack_victim.node.position): return
	var stats = current_stats()
	var strike_damage: float = maxf(1,weapon.damage + stats.bonus_damage)
	if player_status.weaken > 0: strike_damage *= 0.8
	if empowered and mana >= 10:
		mana -= 10
		strike_damage *= 1.75
		pulse(player.position,Color("6ca5ff"),1.1,0.3)
	empowered = false
	var color: Color = Loot.TYPES[weapon.type]
	var attack: String = weapon.get("attack","beam")
	if attack in ["swipe","cleave"]:
		melee_sweep(weapon,strike_damage,color)
	elif attack == "breath":
		breath_attack(weapon,strike_damage,color)
	elif attack == "missile":
		launch_missile(attack_victim.node.position,strike_damage,weapon)
	elif attack == "quills":
		for i in range(3):
			var offset = Vector3((i-1)*0.12,0.8,0)
			beam(player.position+offset,attack_victim.node.position+offset,color)
		apply_enemy_damage(attack_victim,strike_damage,weapon.type,weapon_reach(weapon))
	else:
		beam(player.position+Vector3(0,0.85,0),attack_victim.node.position+Vector3(0,0.7,0),color)
		apply_enemy_damage(attack_victim,strike_damage,weapon.type,weapon_reach(weapon))
	if weapon.get("splash",0) > 0 and attack != "missile":
		pulse(attack_victim.node.position,color,weapon.splash,0.5)
		for enemy in enemies:
			if not is_same(enemy,attack_victim) and enemy.hp > 0 and enemy.node.position.distance_to(attack_victim.node.position) < weapon.splash and clear_shot(attack_victim.node.position,enemy.node.position):
				apply_enemy_damage(enemy,strike_damage*0.5,weapon.type,weapon_reach(weapon))
	if weapon.get("signature",false):
		for enemy in enemies:
			if enemy.hp > 0 and not is_same(enemy,attack_victim) and enemy.node.position.distance_to(attack_victim.node.position) < 3.8 and clear_shot(attack_victim.node.position,enemy.node.position):
				hit_enemy(enemy,strike_damage*0.7)
				break
	tone("hit")
	attack_victim = {}
	attack_weapon = {}

func apply_enemy_damage(enemy: Dictionary, amount: float, kind: String, reach: float = 8.0, include_flat: bool = true):
	if enemy.hp <= 0: return
	var modifiers = current_stats()
	if include_flat and kind == "heat": amount += modifiers.flat_heat
	amount *= 1.0+modifiers.get("damage_"+kind,0)/100.0
	amount *= 1.0+modifiers.get("slayer_"+str(enemy.get("affinity","Cybernetic")).to_lower(),0)/100.0
	var resistance: float = enemy.resists.get(kind,0.0)
	var dealt = amount * (1.0-resistance/100.0)
	if kind == "gravity":
		if rng.randf() < enemy.dodge: return
		# Fixed cap prevents percent-of-Life effects deleting bosses.
		dealt += minf(enemy.max_hp*0.03,amount*0.5)*(1.0-resistance/100.0)
	elif kind == "corruption": dealt *= rng.randf_range(0.5,1.5)
	elif kind == "electromagnetic": dealt *= rng.randf_range(0.8,1.2)
	hit_enemy(enemy,dealt)
	if include_flat and kind != "heat" and modifiers.flat_heat > 0 and enemy.hp > 0:
		apply_enemy_damage(enemy,modifiers.flat_heat,"heat",reach,false)
	if enemy.hp <= 0: return
	if kind in ["heat","radiation"]:
		if enemy.burn <= 0: enemy.tick = 1.0; enemy.burn_damage = 0.0
		enemy.burn = 3.0
		enemy.burn_damage = maxf(enemy.burn_damage,dealt*0.08)
		enemy.dot_type = kind
		enemy.spread = kind == "radiation"
	if kind == "cryogenic":
		enemy.slow = 1.6*(1.0-resistance/100.0)
		enemy.corruption_hits += 1
		if enemy.corruption_hits % 3 == 0: enemy.stop = (0.25 if enemy.boss else 0.55)*(1.0-resistance/100.0)
	if kind == "corruption": enemy.weaken = 3.0*(1.0-resistance/100.0)

func update_statuses(delta: float):
	for enemy in enemies:
		if enemy.hp <= 0: continue
		enemy.weaken = maxf(0,enemy.weaken-delta)
		enemy.slow = maxf(0,enemy.slow-delta)
		enemy.stop = maxf(0,enemy.stop-delta)
		if enemy.burn > 0:
			enemy.burn -= delta
			enemy.tick -= delta
			if enemy.tick <= 0:
				enemy.tick += 1.0
				hit_enemy(enemy,enemy.burn_damage)
				if enemy.spread:
					enemy.spread = false
					for other in enemies:
						if other.hp > 0 and not is_same(other,enemy) and other.burn <= 0 and other.node.position.distance_to(enemy.node.position) < 2.5:
							other.burn = 2.0
							other.tick = 1.0
							other.burn_damage = enemy.burn_damage*0.5*(1.0-other.resists.get("radiation",0)/100.0)
							other.dot_type = "radiation"
							other.spread = false
							beam(enemy.node.position+Vector3.UP,other.node.position+Vector3.UP,Loot.TYPES.radiation)
	for hit in pending_hits.duplicate():
		hit.time -= delta
		if hit.time > 0: continue
		pending_hits.erase(hit)
		if hit.has("enemy"):
			var enemy: Dictionary = hit.enemy
			if enemy.hp > 0 and player_status.stop <= 0 and player.position.distance_to(enemy.node.position) <= hit.reach+0.3 and clear_shot(player.position,enemy.node.position):
				# Each delayed strike is independently avoidable by the target's defenses.
				if rng.randf() >= enemy.dodge:
					beam(player.position+Vector3(0,0.8,0),enemy.node.position+Vector3(0,0.7,0),Loot.TYPES.gravity)
					hit_enemy(enemy,hit.amount)
		elif hp > 0 and hit.source.hp > 0 and player.position.distance_to(hit.origin) < hit.radius and clear_shot(hit.origin,player.position):
			if rng.randf()*100.0 >= current_stats().dodge: damage_player(hit.amount,"gravity",false,hit.source.get("affinity","Cybernetic"))
	player_status.weaken = maxf(0,player_status.weaken-delta)
	player_status.slow = maxf(0,player_status.slow-delta)
	player_status.stop = maxf(0,player_status.stop-delta)
	if player_status.burn > 0:
		player_status.burn -= delta
		player_status.tick -= delta
		if player_status.tick <= 0:
			player_status.tick += 1.0
			damage_player(player_status.burn_damage,player_status.get("dot_type","radiation"),false)

func update_enemy(enemy: Dictionary, delta: float):
	var definition: Dictionary = preload("res://scripts/encounters.gd").TYPES.get(enemy.get("type_id","security"),{})
	if definition.has("weapon"):
		update_arsenal_enemy(enemy,definition,delta)
		return
	if enemy.get("behavior","") == "stationary": return
	var node: Node3D = enemy.node
	var distance = node.position.distance_to(player.position)
	if enemy.stop > 0: return
	enemy.timer -= delta * (0.65 if enemy.slow > 0 else 1.0)
	if enemy.state == "windup":
		enemy.warning.visible = true
		enemy.warning.scale = Vector3.ONE * (enemy.radius / (3.1 if enemy.boss else 1.7)) * (0.97 + sin(clock * 13) * 0.025)
		if enemy.timer <= 0:
			enemy.warning.visible = false
			pulse(node.position, Loot.TYPES[enemy.get("element","physical")], enemy.radius, 0.35)
			if distance < enemy.radius + 0.25 and clear_shot(node.position, player.position):
				var kind: String = enemy.get("element","gravity" if enemy.boss else ["radiation","physical","corruption"][enemy.index % 3])
				damage_player(enemy.attack_damage*(0.8 if enemy.weaken > 0 else 1.0),kind,true,enemy.get("affinity","Cybernetic"))
				if enemy.boss and area == "run":
					for i in [1,2]: pending_hits.append({"source":enemy,"origin":node.position,"radius":enemy.radius+0.25,"amount":enemy.attack_damage,"time":0.22*i})
			enemy.state = "recover"
			enemy.timer = 1.35 if enemy.boss else 1.1
		return
	if enemy.state == "recover":
		if enemy.timer <= 0: enemy.state = "hunt"
		return
	if distance > (8.0 if enemy.boss else 6.0) and enemy.state == "idle": return
	enemy.state = "hunt"
	if enemy.get("behavior","") != "chasing" and distance < (3.0 if enemy.boss else 1.55) and clear_shot(node.position, player.position):
		enemy.attack_number += 1
		enemy.radius = 3.1 if enemy.boss and enemy.attack_number % 2 == 1 else 1.7
		if distance < enemy.radius:
			enemy.state = "windup"
			enemy.timer = 1.05 if enemy.boss else 0.72
			var desired = enemy.radius / (3.1 if enemy.boss else 1.7)
			enemy.warning.scale = Vector3.ONE * desired
			return
	enemy.route_time -= delta
	if enemy.route_time <= 0:
		enemy.route = make_path(node.position, player.position)
		enemy.route_time = 0.5
	var route: Array = enemy.route
	while not route.is_empty() and node.position.distance_to(route[0]) < 0.2: route.pop_front()
	if not route.is_empty():
		var direction = node.position.direction_to(route[0])
		var next = node.position + direction * delta * (1.1 if enemy.boss else 1.5) * (0.65 if enemy.slow > 0 else 1.0)
		var blocked = false
		for other in enemies:
			if not is_same(other, enemy) and other.hp > 0 and next.distance_to(other.node.position) < 0.85: blocked = true
		if not blocked: node.position = next
		enemy.model.rotation.y = lerp_angle(enemy.model.rotation.y, atan2(-direction.x, -direction.z), delta * 7)

func damage_player(amount: float, kind: String = "physical", apply_status: bool = true, affinity: String = ""):
	if affinity != "": amount *= 1.0-current_stats().get("guard_"+affinity.to_lower(),0)/100.0
	if area == "hub" or hp <= 0: return
	var stats = current_stats()
	var resist = float(stats.get(kind,0.0)) if kind != "physical" else 0.0
	if apply_status and kind == "gravity" and rng.randf()*100.0 < stats.dodge: return
	if apply_status and kind == "gravity": amount += minf(stats.max_life*0.03,amount*0.5)
	if apply_status and kind == "corruption": amount *= rng.randf_range(0.5,1.5)
	if apply_status and kind == "electromagnetic": amount *= rng.randf_range(0.8,1.2)
	var dealt = maxf(1,amount-stats.armor) * (1.0-stats.reduction/100.0) * (1.0-resist/100.0)
	dealt = maxf(0,dealt-stats.flat_reduction-(stats.elemental_reduction if kind != "physical" else 0.0))
	hp = maxf(0,hp-dealt)
	if apply_status and kind in ["heat","radiation"]:
		if player_status.burn <= 0:
			player_status.tick = 1.0
			player_status.burn_damage = 0.0
		player_status["dot_type"] = kind
		player_status.burn = 3.0
		player_status.burn_damage = maxf(player_status.burn_damage,amount*0.08)
	if apply_status and kind == "corruption": player_status.weaken = 3.0*(1.0-resist/100.0)
	if apply_status and kind == "cryogenic":
		player_status.slow = 1.6*(1.0-resist/100.0)
		player_status.stop = 0.35*(1.0-resist/100.0)
	pulse(player.position, Color("ff766d"), 0.8, 0.3)
	tone("hurt")
	if stats.circuit and charge >= 1.5 and circuit_cooldown <= 0:
		charge = 0
		circuit_cooldown = 5
		pulse(player.position, Color("b3ff9c"), 3.3, 0.65)
		for enemy in enemies:
			if enemy.hp > 0 and enemy.node.position.distance_to(player.position) < 3.3: hit_enemy(enemy, 24)
		toast("EMERGENCY RETURN discharged · 5s recovery", 3)
	if hp <= 0:
		path.clear()
		pet.rotation.z = 1.1
		toast("Defeated. T returns to the garage.",60)

func hit_enemy(enemy: Dictionary, amount: float):
	if enemy.hp <= 0: return
	enemy.hp = maxf(0, enemy.hp - amount)
	enemy.label.text = "%s / %d" % [enemy.title, int(enemy.hp)]
	pulse(enemy.node.position, Color("f4d183"), 0.6, 0.22)
	if enemy.hp <= 0:
		if is_same(target_enemy, enemy):
			target_enemy = {}
			path.clear()
		enemy.warning.visible = false
		enemy.label.text = ""
		enemy.model.rotation.z = PI / 2
		enemy.model.position.y = 0.2
		if area == "debug_arena": return
		if enemy.get("type_id","") == "chefbot":
			spawn_drop(enemy.node.position,Loot.chefbot_hat())
			if chef_quest != "complete": chef_quest = "defeated"
			toast("CHEFBOT DEFEATED / Unique hat recovered. Report to Dispatch.",8)
		if enemy.get("type_id","") == "obesecat":
			act_complete = true
			pulse(enemy.node.position,Color("fff2bc"),7.0,1.5)
		silicon += Loot.Bonuses.silicon(enemy.silicon_reward,current_stats().silicon_discovery)
		# Deterministic supply recovery does not perturb equipment RNG.
		if enemy.boss or enemy.index % 3 == 0:
			add_potions("life" if enemy.index % 2 == 0 else "mana",1)
		# Bounded loot: supervisor plus at most two regular drops per tower floor.
		var drop_rng = WorldRandom.stream(run_seed,run_number,area,"enemy_loot",enemy.index)
		var did_drop = (enemy.boss and not Tower.ZONES.has(area)) or (not enemy.boss and salvage_count < (2 if Tower.ZONES.has(area) else 1) and drop_rng.randf() < 0.3)
		if did_drop:
			spawn_drop(enemy.node.position,Tower.salvage(drop_rng,area,current_stats().item_discovery,enemy.get("affinity","Cybernetic")) if Tower.ZONES.has(area) else Loot.make_item("weapon",0,rng,false,1))
			if not enemy.boss: salvage_count += 1
		if hp > 0: hp = minf(current_stats().max_life, hp + 10)
		toast("Security unit disabled. +%d XP / +10 Life.%s" % [enemy.xp_reward, " Salvage recovered." if did_drop else ""], 3)
		award_xp(enemy.xp_reward)
		if Tower.ZONES.has(area) and enemy.boss:
			Chests.build(self,Chests.create(self,4 if area == "obesecat" else 3,enemy.node.position,WorldRandom.derive(run_seed,run_number,area,"boss_chest",enemy.index)))
			if area in Tower.FLOOR_ORDER and not keycards.has(area):
				keycards.append(area)
				toast("KEYCARD RECOVERED / " + Tower.ZONES[area].name + ". Elevator stop and upward route authorized.",10)
			elif area not in Tower.FLOOR_ORDER: toast("Side-area supervisor disabled. Salvage recovered.",6)
		if living_enemies() == 0:
			won = true
			if area == "run": Hub.gate(self,SPAWN,"return","RETURN TO GARAGE",Color("aeeaa1"))

func spawn_drop(pos: Vector3, item: Dictionary):
	var node = Node3D.new()
	dynamic.add_child(node)
	node.position = pos
	var color = Loot.color(item)
	var gem = Models.box(node, Vector3(0, 0.4, 0), Vector3(0.3, 0.45, 0.3), color, true)
	gem.rotation.z = 0.4
	Models.ring(node, 0.42, color)
	for tier_step in range(maxi(0,item.get("tier",0)-1)):
		Models.ring(node,0.50+tier_step*0.10,Color(color,0.35+tier_step*0.12))
	var label = Models.text3d(node, Loot.label(item) + " [E]", Vector3(0, 1.15, 0), color, 28)
	label.pixel_size = 0.014
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	drops.append({"node": node, "gem": gem, "item": item})

func pickup(drop: Dictionary):
	if not drops.has(drop): return
	if is_same(target_drop, drop): target_drop = {}
	if not add_to_backpack(drop.item):
		toast("BACKPACK FULL: need %dx%d clear cells. Loot stays on the ground." % [drop.item.width, drop.item.height], 5)
		return
	hud.selection = inventory.size() - 1
	toast("Recovered " + drop.item.name + ". I to compare / equip.", 5)
	drops.erase(drop)
	drop.node.queue_free()
	tone("equip")

func collect_nearby():
	var found = false
	for drop in drops.duplicate():
		if player.position.distance_to(drop.node.position) < 2.1:
			pickup(drop)
			found = true
	if not found: toast("Move closer to a salvage beacon, then E. Or click the drop.", 3)

func update_fault(delta: float):
	fault_time += delta
	if fault_time >= 7:
		fault_time = 0
		fault_fired = false
	var warning = fault_time >= 4.8 and fault_time < 6.2
	fault_ring.material_override.albedo_color = Color("f0a1e0") if warning else Color("694e76")
	fault_ring.scale = Vector3.ONE * (1.0 + sin(clock * 8) * 0.04 if warning and effects_enabled else 1.0)
	for i in range(fault_echo.get_child_count()):
		var child = fault_echo.get_child(i)
		child.position.x = sin(floor(clock * 6) + i * 2.0) * (0.5 if warning else 0.15) if effects_enabled else 0
	if fault_time >= 6.2 and not fault_fired:
		fault_fired = true
		pulse(FAULT, Color("ed8bdd"), 2.0, 0.5)
		if player.position.distance_to(FAULT) < 2.0:
			damage_player(14,"corruption")
			toast("Signal fault pulse. The magenta ring warns before discharge.", 3)

func pulse(pos: Vector3, color: Color, radius: float, duration: float):
	var node = Node3D.new()
	dynamic.add_child(node)
	node.position = pos
	Models.ring(node, radius, color)
	effects.append({"node": node, "time": duration, "duration": duration, "expand": true})

func beam(from: Vector3, to: Vector3, color: Color):
	var node = Node3D.new()
	dynamic.add_child(node)
	node.position = (from + to) / 2
	Models.box(node, Vector3.ZERO, Vector3(0.08, 0.08, from.distance_to(to)), color, true)
	node.look_at(to)
	effects.append({"node": node, "time": 0.16, "duration": 0.16, "expand": false})

func update_effects(delta: float):
	for effect in effects.duplicate():
		if effect.get("missile",false):
			effect.node.position = effect.node.position.move_toward(effect.target,delta*8.0)
			effect.smoke -= delta
			if effect.smoke <= 0:
				effect.smoke = 0.06
				var puff = Node3D.new()
				dynamic.add_child(puff)
				puff.position = effect.node.position
				Models.sphere(puff,Vector3.ZERO,Vector3.ONE*0.3,Color("6a7178"))
				effects.append({"node":puff,"time":0.7,"duration":0.7,"expand":true})
			if effect.node.position.distance_to(effect.target) < 0.15:
				pulse(effect.target,Loot.TYPES[effect.kind],effect.radius,0.65)
				var flash = Node3D.new()
				dynamic.add_child(flash)
				flash.position = effect.target
				var fire = Models.sphere(flash,Vector3.ZERO,Vector3.ONE*effect.radius,Loot.TYPES[effect.kind])
				fire.material_override.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
				effects.append({"node":flash,"time":0.18,"duration":0.18,"expand":true})
				if effect.get("hostile",false) and player.position.distance_to(effect.target-Vector3.UP*0.7) <= effect.radius and clear_shot(effect.target,player.position):
					damage_player(effect.damage,effect.kind,true,"Cybernetic")
				for enemy in enemies:
					if not effect.get("hostile",false) and enemy.hp > 0 and enemy.node.position.distance_to(effect.target-Vector3.UP*0.7) <= effect.radius and clear_shot(effect.target,enemy.node.position):
						apply_enemy_damage(enemy,effect.damage,effect.kind,effect.get("reach",8.0))
				effect.time = 0
		if effect.has("sweep"):
			effect.node.rotation.y = effect.start_angle + effect.sweep*(1.0-effect.time/effect.duration)
		effect.time -= delta
		if effect.time <= 0:
			effect.node.queue_free()
			effects.erase(effect)
		elif effect.expand:
			effect.node.scale = Vector3.ONE * (1.0 - effect.time / effect.duration * 0.55)

func build_audio():
	audio = AudioStreamPlayer.new()
	add_child(audio)
	audio.volume_db = -19
	for kind in ["hit", "hurt", "equip"]:
		var samples = PackedByteArray()
		var count = 6615
		samples.resize(count * 2)
		for i in range(count):
			var t = float(i) / 22050
			var frequency = 240.0 if kind == "hit" else (95.0 if kind == "hurt" else 620.0)
			var sample = sin(TAU * frequency * t * (1.0 - t * 0.7)) * exp(-t * 20) * 0.65
			var value = int(sample * 32767)
			samples.encode_s16(i * 2, value)
		var stream = AudioStreamWAV.new()
		stream.format = AudioStreamWAV.FORMAT_16_BITS
		stream.mix_rate = 22050
		stream.data = samples
		tones[kind] = stream

func tone(kind: String):
	if sound_enabled:
		audio.stream = tones[kind]
		audio.play()

func melee_sweep(weapon: Dictionary, damage: float, color: Color):
	var mount = pet.get_node_or_null("Gear/"+weapon.get("mount","WeaponLeft" if is_same(weapon,equipment.left) else "WeaponRight"))
	if is_instance_valid(mount):
		var tween = create_tween()
		tween.tween_property(mount,"rotation:y",-1.1,0.06)
		tween.tween_property(mount,"rotation:y",1.1,0.3 if weapon.get("attack","") == "cleave" else 0.12)
		tween.tween_property(mount,"rotation:y",0.0,0.12)
	var wide: bool = weapon.get("attack","") == "cleave"
	var reach = weapon_reach(weapon)
	var arc = minf(PI,(2.6 if wide else 1.4)*(1.0+current_stats().melee_arc/100.0))
	var direction = player.position.direction_to(attack_victim.node.position)
	var angle = atan2(-direction.x,-direction.z)
	var swing = Node3D.new()
	dynamic.add_child(swing)
	swing.position = player.position+Vector3.UP*0.85
	swing.rotation.y = angle-arc/2
	Models.box(swing,Vector3(0,0,-reach/2),Vector3(0.16,0.16,reach),color,true)
	for i in range(10):
		var a = -arc/2+arc*i/9.0+angle
		var trace = Node3D.new()
		dynamic.add_child(trace)
		trace.position = player.position+Vector3(-sin(a)*reach,0.8,-cos(a)*reach)
		Models.box(trace,Vector3.ZERO,Vector3(0.15,0.06,0.15),color,true)
		effects.append({"node":trace,"time":0.3 if wide else 0.16,"duration":0.3,"expand":false})
	effects.append({"node":swing,"time":0.38 if wide else 0.16,"duration":0.38 if wide else 0.16,"expand":false,"sweep":arc,"start_angle":angle-arc/2})
	for enemy in enemies:
		var offset: Vector3 = enemy.node.position-player.position
		if enemy.hp > 0 and offset.length() <= reach+0.3 and direction.dot(offset.normalized()) >= cos(arc/2) and clear_shot(player.position,enemy.node.position):
			apply_enemy_damage(enemy,damage,weapon.type,reach)

func launch_missile(target: Vector3, damage: float, weapon: Dictionary):
	var missile = Node3D.new()
	dynamic.add_child(missile)
	missile.position = player.position+Vector3.UP*0.9
	var destination = target+Vector3.UP*0.7
	Models.box(missile,Vector3.ZERO,Vector3(0.22,0.22,0.65),Color("d9dedb"))
	Models.sphere(missile,Vector3(0,0,0.4),Vector3(0.2,0.2,0.4),Loot.TYPES[weapon.type])
	missile.look_at(destination)
	effects.append({"node":missile,"time":3.0,"duration":3.0,"expand":false,"missile":true,"target":destination,"smoke":0.0,"damage":damage,"kind":weapon.type,"reach":weapon_reach(weapon) if weapon.has("reach") else 8.0,"radius":weapon.get("splash",2.1)*(1.0+current_stats().explosion_radius/100.0)})

func weapon_reach(weapon: Dictionary) -> float:
	var key = "melee_arc" if weapon.get("attack","") in ["swipe","cleave"] else "projectile_range"
	return float(weapon.reach)*(1.0+current_stats().get(key,0)/100.0)

func apply_world_seed(value: int) -> bool:
	if not ((area == "hub" and menu_open == "debug") or (area == "debug_arena" and menu_open == "arena_control")): return false
	if value < 1 or value > 2147483646: return false
	var destination = area
	run_seed = value
	run_number = 0
	zone_states.clear()
	arena_open_counts.clear()
	wormhole.clear()
	visited.clear()
	act_complete = false
	rng.seed = WorldRandom.derive(run_seed,0,"global","combat")
	shops = Economy.stock(run_seed,shop_tier())
	restart(false,true,destination)
	toast("WORLD SEED %d / encounters and floor loot rebuilt; character and keycards retained" % run_seed,8)
	return true

func update_arsenal_enemy(enemy: Dictionary, definition: Dictionary, delta: float):
	if enemy.stop > 0: return
	var pos: Vector3 = enemy.node.position
	var distance = pos.distance_to(player.position)
	enemy.timer -= delta*(0.65 if enemy.slow > 0 else 1.0)
	if enemy.state == "aim":
		if enemy.timer <= 0:
			enemy.warning.visible = false
			fire_enemy_weapon(enemy,definition)
			enemy.state = "cooldown"
			enemy.timer = definition.period
		return
	if enemy.state == "cooldown" and enemy.timer > 0: return
	if distance <= definition.reach and clear_shot(pos,player.position):
		enemy.aim = player.position
		enemy.state = "aim"
		enemy.timer = definition.windup
		enemy.warning.visible = true
		enemy.model.rotation.y = atan2(-(player.position.x-pos.x),-(player.position.z-pos.z))
		if definition.weapon == "rocket": pulse(enemy.aim,Loot.TYPES[definition.element],2.0,definition.windup)
		return
	if definition.behavior == "stationary": return
	var destination: Vector3 = player.position
	if distance > 9.0:
		if definition.behavior != "patrolling": return
		destination = enemy.home+Vector3(2.0 if enemy.patrol_leg == 0 else -2.0,0,0)
		if pos.distance_to(destination) < 0.4: enemy.patrol_leg = 1-enemy.patrol_leg
	enemy.route_time -= delta
	if enemy.route_time <= 0:
		enemy.route = make_path(pos,destination)
		enemy.route_time = 0.5
	while not enemy.route.is_empty() and pos.distance_to(enemy.route[0]) < 0.2: enemy.route.pop_front()
	if not enemy.route.is_empty():
		var direction: Vector3 = pos.direction_to(enemy.route[0])
		enemy.node.position += direction*delta*1.5*(0.65 if enemy.slow > 0 else 1.0)
		enemy.model.rotation.y = lerp_angle(enemy.model.rotation.y,atan2(-direction.x,-direction.z),delta*6)

func fire_enemy_weapon(enemy: Dictionary, definition: Dictionary):
	var pos: Vector3 = enemy.node.position
	var amount: float = enemy.attack_damage*(0.8 if enemy.weaken > 0 else 1.0)
	if definition.weapon == "rocket":
		var rocket = Node3D.new()
		dynamic.add_child(rocket)
		rocket.position = pos+Vector3.UP
		Models.box(rocket,Vector3.ZERO,Vector3(0.22,0.22,0.7),Loot.TYPES[definition.element])
		var target: Vector3 = enemy.aim+Vector3.UP*0.7
		rocket.look_at(target)
		effects.append({"node":rocket,"time":4.0,"duration":4.0,"expand":false,"missile":true,"hostile":true,"target":target,"smoke":0.0,"damage":amount,"kind":definition.element,"radius":2.0 if not enemy.boss else 2.8})
	elif definition.weapon == "laser":
		var target: Vector3 = enemy.aim
		beam(pos+Vector3.UP,target+Vector3.UP,Loot.TYPES[definition.element])
		var nearest = Geometry3D.get_closest_point_to_segment(player.position,pos,target)
		if nearest.distance_to(player.position) < 0.6 and clear_shot(pos,player.position): damage_player(amount,definition.element,true,enemy.affinity)
	else:
		var facing = pos.direction_to(enemy.aim)
		pulse(pos+facing,Loot.TYPES[definition.element],1.2,0.25)
		beam(pos+Vector3.UP,pos+facing*definition.reach+Vector3.UP,Loot.TYPES[definition.element])
		if pos.distance_to(player.position) <= definition.reach and facing.dot(pos.direction_to(player.position)) >= 0.5 and clear_shot(pos,player.position): damage_player(amount,definition.element,true,enemy.affinity)

func breath_attack(weapon: Dictionary, damage: float, color: Color):
	var direction = player.position.direction_to(attack_victim.node.position)
	var reach = weapon_reach(weapon)
	# Five visible pellet streams; deterministic cone damage once per target.
	for i in range(5):
		var ray = direction.rotated(Vector3.UP,(i-2)*0.16)
		for step in range(1,5):
			var particle = Node3D.new()
			dynamic.add_child(particle)
			particle.position = player.position+Vector3.UP*0.8+ray*step*reach/4
			Models.sphere(particle,Vector3.ZERO,Vector3.ONE*(0.08+step*0.035),color)
			effects.append({"node":particle,"time":0.15+step*0.04,"duration":0.31,"expand":true})
	for enemy in enemies:
		var offset: Vector3 = enemy.node.position-player.position
		if enemy.hp > 0 and offset.length() <= reach and direction.dot(offset.normalized()) >= cos(0.4) and clear_shot(player.position,enemy.node.position):
			apply_enemy_damage(enemy,damage,weapon.type,reach)
