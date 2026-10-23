extends RefCounted
## Persistent disk saves for ObeseCat ArcLight playtesting.
## Serializes character progression, backpack/equipment layout, Silicon,
## keycards, world seed, quest state, shops/buyback and per-floor zone snapshots to JSON.

const SAVE_PATH = "user://arclight_save.json"
const VERSION = 1

const Tower = preload("res://scripts/tower.gd")
const Loot = preload("res://scripts/loot.gd")
const Backpack = preload("res://scripts/backpack.gd")
const Progression = preload("res://scripts/progression.gd")
const Models = preload("res://scripts/models.gd")

static func has_save(path: String = SAVE_PATH) -> bool:
	return FileAccess.file_exists(path)

static func delete_save(path: String = SAVE_PATH) -> bool:
	if not FileAccess.file_exists(path): return false
	var dir = DirAccess.open("user://")
	if dir:
		var fname = path.replace("user://", "")
		return dir.remove(fname) == OK
	return false

static func read_summary(path: String = SAVE_PATH) -> Dictionary:
	if not has_save(path): return {}
	var file = FileAccess.open(path, FileAccess.READ)
	if not file: return {}
	var text = file.get_as_text()
	file.close()
	var json = JSON.new()
	if json.parse(text) != OK: return {}
	if typeof(json.data) != TYPE_DICTIONARY: return {}
	return json.data.get("summary", {})

static func vec3_to_dict(v: Vector3) -> Dictionary:
	return {"x": snappedf(v.x, 0.001), "y": snappedf(v.y, 0.001), "z": snappedf(v.z, 0.001)}

static func dict_to_vec3(d) -> Vector3:
	if typeof(d) != TYPE_DICTIONARY: return Vector3.ZERO
	return Vector3(float(d.get("x", 0.0)), float(d.get("y", 0.0)), float(d.get("z", 0.0)))

static func vec2i_to_dict(v: Vector2i) -> Dictionary:
	return {"x": v.x, "y": v.y}

static func dict_to_vec2i(d) -> Vector2i:
	if typeof(d) == TYPE_DICTIONARY:
		return Vector2i(int(d.get("x", -1)), int(d.get("y", -1)))
	elif typeof(d) == TYPE_ARRAY and d.size() >= 2:
		return Vector2i(int(d[0]), int(d[1]))
	return Backpack.NOWHERE

static func serialize_item(item: Dictionary) -> Dictionary:
	var copy = item.duplicate(true)
	if copy.has("grid_pos") and copy.grid_pos is Vector2i:
		copy["grid_pos"] = vec2i_to_dict(copy.grid_pos)
	return copy

static func deserialize_item(data: Dictionary) -> Dictionary:
	var item = data.duplicate(true)
	if item.has("grid_pos"):
		item["grid_pos"] = dict_to_vec2i(item.grid_pos)
	else:
		item["grid_pos"] = Backpack.NOWHERE
	return item

static func save_game(game, path: String = SAVE_PATH) -> bool:
	if not game.started: return false
	if Tower.ZONES.has(game.area): game.save_zone()

	var area_label = "Garage Refuge"
	if Tower.ZONES.has(game.area): area_label = Tower.ZONES[game.area].name
	elif game.area == "debug_arena": area_label = "Test Range"

	var data = {
		"version": VERSION,
		"timestamp": int(Time.get_unix_time_from_system()),
		"summary": {
			"level": game.progression.level,
			"silicon": game.silicon,
			"area": game.area,
			"area_name": area_label,
			"keycards_count": game.keycards.size(),
			"act_complete": game.act_complete,
			"datetime": Time.get_datetime_string_from_system(false, true)
		},
		"character": {
			"level": game.progression.level,
			"xp": game.progression.xp,
			"points": game.progression.points,
			"skill_points": game.progression.skill_points,
			"skills": game.skills.duplicate(true),
			"assigned_skill": game.assigned_skill,
			"attributes": game.progression.attributes.duplicate(true),
			"hp": game.hp,
			"mana": game.mana,
			"potions": game.potions.duplicate(true),
			"silicon": game.silicon
		},
		"inventory": [],
		"equipped_indices": {},
		"world": {
			"run_seed": game.run_seed,
			"run_number": game.run_number,
			"area": game.area,
			"player_pos": vec3_to_dict(game.player.position) if is_instance_valid(game.player) else {"x": 0.0, "y": 0.0, "z": 4.0},
			"keycards": game.keycards.duplicate(true),
			"visited": game.visited.duplicate(true),
			"act_complete": game.act_complete,
			"chef_quest": game.chef_quest,
			"arena_open_counts": game.arena_open_counts.duplicate(true),
			"wormhole": {},
			"buyback": [],
			"shops": {},
			"hub_ground": [],
			"zone_states": {}
		}
	}

	# Serialize inventory items
	for item in game.inventory:
		data.inventory.append(serialize_item(item))

	# Record which inventory index is equipped in each slot
	for slot in Loot.SLOTS:
		var equipped = game.equipment.get(slot, {})
		var idx = -1
		if equipped.get("model", -1) >= 0:
			for i in range(game.inventory.size()):
				if is_same(game.inventory[i], equipped):
					idx = i
					break
		data.equipped_indices[slot] = idx

	# Wormhole
	if not game.wormhole.is_empty():
		data.world.wormhole = {
			"area": game.wormhole.area,
			"pos": vec3_to_dict(game.wormhole.pos)
		}

	# Buyback
	for entry in game.buyback:
		data.world.buyback.append({
			"item": serialize_item(entry.item),
			"price": entry.price
		})

	# Vendor stock
	for shop_name in game.shops:
		var shop_items = []
		for it in game.shops[shop_name]:
			shop_items.append(serialize_item(it))
		data.world.shops[shop_name] = shop_items

	# Hub ground items
	for drop in game.hub_ground:
		data.world.hub_ground.append({
			"item": serialize_item(drop.item),
			"pos": vec3_to_dict(drop.pos)
		})

	# Zone snapshots
	for z_name in game.zone_states:
		var snap = game.zone_states[z_name]
		var s_enemies = []
		for e in snap.get("enemies", []):
			s_enemies.append({"hp": float(e.get("hp", 0.0)), "pos": vec3_to_dict(e.get("pos", Vector3.ZERO))})
		var s_drops = []
		for d in snap.get("drops", []):
			s_drops.append({"item": serialize_item(d.get("item", {})), "pos": vec3_to_dict(d.get("pos", Vector3.ZERO))})
		var s_chests = []
		for c in snap.get("chests", []):
			var c_items = []
			for it in c.get("items", []):
				c_items.append(serialize_item(it))
			s_chests.append({
				"kind": int(c.get("kind", 0)),
				"pos": vec3_to_dict(c.get("pos", Vector3.ZERO)),
				"opened": bool(c.get("opened", false)),
				"items": c_items,
				"silicon": int(c.get("silicon", 0)),
				"life": int(c.get("life", 0)),
				"mana": int(c.get("mana", 0))
			})
		data.world.zone_states[z_name] = {
			"enemies": s_enemies,
			"drops": s_drops,
			"chests": s_chests,
			"salvage": int(snap.get("salvage", 0)),
			"rng": int(snap.get("rng", 0))
		}

	var file = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		push_error("Failed to open save file for writing: " + path)
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return true

static func load_game(game, path: String = SAVE_PATH) -> bool:
	if not FileAccess.file_exists(path): return false
	var file = FileAccess.open(path, FileAccess.READ)
	if not file: return false
	var text = file.get_as_text()
	file.close()

	var json = JSON.new()
	if json.parse(text) != OK:
		push_error("Failed to parse save JSON: " + json.get_error_message())
		return false
	var data = json.data
	if typeof(data) != TYPE_DICTIONARY: return false

	var world_data: Dictionary = data.get("world", {})

	# 1. Determine destination area and clean transition first
	var target_area = str(world_data.get("area", "hub"))
	if not Tower.ZONES.has(target_area) and target_area != "hub":
		target_area = "hub"
	var saved_player_pos = dict_to_vec3(world_data.get("player_pos", {}))

	# Rebuild area environment without carrying prior in-memory session baggage
	game.restart(false, true, target_area)

	# 2. Restore World & Meta
	game.run_seed = int(world_data.get("run_seed", game.run_seed))
	game.run_number = int(world_data.get("run_number", 0))
	game.keycards = world_data.get("keycards", []).duplicate(true)
	game.visited = world_data.get("visited", []).duplicate(true)
	game.act_complete = bool(world_data.get("act_complete", false))
	game.chef_quest = str(world_data.get("chef_quest", "locked"))
	game.arena_open_counts = world_data.get("arena_open_counts", {}).duplicate(true)

	if world_data.has("wormhole") and not world_data.wormhole.is_empty():
		game.wormhole = {
			"area": str(world_data.wormhole.get("area", "")),
			"pos": dict_to_vec3(world_data.wormhole.get("pos", {}))
		}
	else:
		game.wormhole.clear()

	# Buyback
	game.buyback.clear()
	for entry in world_data.get("buyback", []):
		game.buyback.append({
			"item": deserialize_item(entry.get("item", {})),
			"price": int(entry.get("price", 0))
		})

	# Shops
	game.shops.clear()
	var shops_data: Dictionary = world_data.get("shops", {})
	for shop_name in shops_data:
		var s_list = []
		for item_data in shops_data[shop_name]:
			s_list.append(deserialize_item(item_data))
		game.shops[shop_name] = s_list

	# Hub ground
	game.hub_ground.clear()
	for drop_data in world_data.get("hub_ground", []):
		game.hub_ground.append({
			"item": deserialize_item(drop_data.get("item", {})),
			"pos": dict_to_vec3(drop_data.get("pos", {}))
		})
	if target_area == "hub":
		for saved in game.hub_ground:
			game.spawn_drop(saved.pos, saved.item)

	# Zone snapshots
	game.zone_states.clear()
	var z_states_data: Dictionary = world_data.get("zone_states", {})
	for z_name in z_states_data:
		var snap_data: Dictionary = z_states_data[z_name]
		var enemies = []
		for e in snap_data.get("enemies", []):
			enemies.append({"hp": float(e.get("hp", 0.0)), "pos": dict_to_vec3(e.get("pos", {}))})
		var drops = []
		for d in snap_data.get("drops", []):
			drops.append({"item": deserialize_item(d.get("item", {})), "pos": dict_to_vec3(d.get("pos", {}))})
		var chests = []
		for c in snap_data.get("chests", []):
			var c_items = []
			for it in c.get("items", []):
				c_items.append(deserialize_item(it))
			chests.append({
				"kind": int(c.get("kind", 0)),
				"pos": dict_to_vec3(c.get("pos", {})),
				"opened": bool(c.get("opened", false)),
				"items": c_items,
				"silicon": int(c.get("silicon", 0)),
				"life": int(c.get("life", 0)),
				"mana": int(c.get("mana", 0))
			})
		game.zone_states[z_name] = {
			"enemies": enemies,
			"drops": drops,
			"chests": chests,
			"salvage": int(snap_data.get("salvage", 0)),
			"rng": int(snap_data.get("rng", 0))
		}
	if Tower.ZONES.has(target_area):
		game.restore_zone()

	# 3. Progression & Character
	var char_data: Dictionary = data.get("character", {})
	game.progression.level = int(char_data.get("level", 1))
	game.progression.xp = int(char_data.get("xp", 0))
	game.progression.points = int(char_data.get("points", 0))
	game.progression.skill_points = int(char_data.get("skill_points", 0))
	if char_data.has("skills") and typeof(char_data.skills) == TYPE_DICTIONARY:
		for s_id in Skills.LIST:
			game.skills[s_id] = int(char_data.skills.get(s_id, 1 if s_id == "projectile" else 0))
	if char_data.has("assigned_skill"):
		game.assigned_skill = str(char_data.assigned_skill)
	var attrs: Dictionary = char_data.get("attributes", {})
	for a in Progression.ATTRIBUTES:
		game.progression.attributes[a] = int(attrs.get(a, 10))
	game.silicon = int(char_data.get("silicon", 80))
	game.potions = char_data.get("potions", {"life": 6, "mana": 4}).duplicate(true)
	game.potion_cooldowns = {"life": 0.0, "mana": 0.0}

	# 4. Inventory & Equipment
	game.inventory.clear()
	for item_data in data.get("inventory", []):
		game.inventory.append(deserialize_item(item_data))

	game.equipment.clear()
	var eq_indices: Dictionary = data.get("equipped_indices", {})
	for slot in Loot.SLOTS:
		var idx = int(eq_indices.get(slot, -1))
		if idx >= 0 and idx < game.inventory.size():
			game.equipment[slot] = game.inventory[idx]
		else:
			game.equipment[slot] = Loot.empty_item(slot)

	# Restore 3D pet gear models
	if is_instance_valid(game.pet):
		Models.equip(game.pet, game.equipment)

	# Restore saved player pos if valid in non-hub zone
	if target_area != "hub" and saved_player_pos != Vector3.ZERO and is_instance_valid(game.player):
		game.player.position = saved_player_pos

	# Restore HP / Mana
	var stats = game.current_stats()
	game.hp = clampf(float(char_data.get("hp", stats.max_life)), 1.0, stats.max_life)
	game.mana = clampf(float(char_data.get("mana", stats.max_mana)), 0.0, stats.max_mana)

	game.sync_wormhole()
	game.build_navigation()

	game.started = true
	if is_instance_valid(game.hud):
		game.hud.selection = 0 if not game.inventory.is_empty() else -1
		game.hud.refresh_inventory()
		game.hud.refresh_character()
		game.hud.update_hud()
	game.toast("Game loaded from disk.", 3)
	return true
