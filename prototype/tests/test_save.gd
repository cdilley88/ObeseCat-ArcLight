extends SceneTree

const Game = preload("res://scripts/main.gd")
const SaveManager = preload("res://scripts/save_manager.gd")
const Loot = preload("res://scripts/loot.gd")
const Backpack = preload("res://scripts/backpack.gd")
const TEST_SAVE_PATH = "user://test_save_playtest.json"

var checks = 0
var failures = 0

func check(ok: bool, why: String):
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + why)

func _initialize():
	call_deferred("run")

func run():
	# Ensure test save path starts clean
	SaveManager.delete_save(TEST_SAVE_PATH)
	check(not SaveManager.has_save(TEST_SAVE_PATH), "clean test save environment")

	# Test 1: Vector & item helpers
	var v3 = Vector3(1.234, -5.678, 9.101)
	var d3 = SaveManager.vec3_to_dict(v3)
	var v3_back = SaveManager.dict_to_vec3(d3)
	check(v3.distance_to(v3_back) < 0.005, "Vector3 serialization round trip")

	var v2 = Vector2i(7, 4)
	var d2 = SaveManager.vec2i_to_dict(v2)
	var v2_back = SaveManager.dict_to_vec2i(d2)
	check(v2 == v2_back, "Vector2i serialization round trip")

	var rng = RandomNumberGenerator.new()
	rng.seed = 42
	var test_item = Loot.make_item("weapon", 1, rng, true, 3, 2)
	test_item.grid_pos = Vector2i(3, 2)
	var serialized_item = SaveManager.serialize_item(test_item)
	check(serialized_item.grid_pos is Dictionary, "item grid_pos serialized to dict")
	var deserialized_item = SaveManager.deserialize_item(serialized_item)
	check(deserialized_item.grid_pos is Vector2i and deserialized_item.grid_pos == Vector2i(3, 2), "item grid_pos restored to Vector2i")
	check(deserialized_item.name == test_item.name and deserialized_item.damage == test_item.damage, "item attributes preserved")

	# Test 2: Full game state serialization & save
	var game = Game.new()
	game.run_seed = 123456
	root.add_child(game)
	game.sound_enabled = false
	game.set_physics_process(false)
	game.begin()
	await process_frame
	await physics_frame

	# Modify state
	game.progression.level = 4
	game.progression.xp = 35
	game.progression.points = 7
	game.progression.skill_points = 2
	game.skills = {"projectile": 2, "nova": 1, "hazard": 0, "overdrive": 0}
	game.assigned_skill = "nova"
	game.progression.attributes["strength"] = 15
	game.progression.attributes["vitality"] = 14
	game.silicon = 450
	game.potions = {"life": 12, "mana": 8}
	game.keycards = ["lobby", "maintenance"]
	game.visited = ["lobby", "concourse", "maintenance"]
	game.act_complete = false
	game.chef_quest = "active"

	# Add extra items to inventory
	var head_item = Loot.make_item("head", 1, rng, true, 2, 1)
	head_item.grid_pos = Vector2i(0, 0)
	game.inventory.append(head_item)
	game.equip_item(game.inventory.size() - 1, "head")

	# Drop an item in hub
	var ground_item = Loot.make_item("neck", 0, rng, false)
	game.hub_ground.append({"item": ground_item, "pos": Vector3(1.5, 0.0, -2.0)})

	# Add buyback entry
	var buyback_item = Loot.make_item("harness", 0, rng, false)
	game.buyback.append({"item": buyback_item, "price": 45})

	# Cast wormhole
	game.wormhole = {"area": "maintenance", "pos": Vector3(0.0, 0.0, 5.0)}

	# Save game to test path
	var save_result = SaveManager.save_game(game, TEST_SAVE_PATH)
	check(save_result, "SaveManager.save_game succeeded")
	check(SaveManager.has_save(TEST_SAVE_PATH), "save file exists on disk")

	# Test 3: Read summary
	var summary = SaveManager.read_summary(TEST_SAVE_PATH)
	check(summary.get("level", 0) == 4, "summary level matches")
	check(summary.get("silicon", 0) == 450, "summary silicon matches")
	check(summary.get("area", "") == "hub", "summary area matches")
	check(summary.get("keycards_count", 0) == 2, "summary keycards count matches")

	# Clean up first game instance
	root.remove_child(game)
	game.queue_free()
	await process_frame

	# Test 4: Load into fresh Game instance
	var loaded_game = Game.new()
	root.add_child(loaded_game)
	loaded_game.sound_enabled = false
	loaded_game.set_physics_process(false)
	# Verify fresh start initial state before load
	check(loaded_game.progression.level == 1 and loaded_game.silicon == 80, "fresh game starts level 1 / 80 silicon")

	# Perform load
	var load_result = SaveManager.load_game(loaded_game, TEST_SAVE_PATH)
	check(load_result, "SaveManager.load_game succeeded")
	await process_frame
	await physics_frame

	# Verify character progression restored
	check(loaded_game.progression.level == 4, "loaded level 4")
	check(loaded_game.progression.xp == 35, "loaded xp 35")
	check(loaded_game.progression.points == 7, "loaded points 7")
	check(loaded_game.progression.skill_points == 2, "loaded skill_points 2")
	check(loaded_game.skills.get("projectile", 0) == 2, "loaded projectile rank 2")
	check(loaded_game.skills.get("nova", 0) == 1, "loaded nova rank 1")
	check(loaded_game.assigned_skill == "nova", "loaded assigned_skill nova")
	check(loaded_game.progression.attributes["strength"] == 15, "loaded strength 15")
	check(loaded_game.progression.attributes["vitality"] == 14, "loaded vitality 14")
	check(loaded_game.silicon == 450, "loaded silicon 450")
	check(loaded_game.potions.life == 12 and loaded_game.potions.mana == 8, "loaded potions 12/8")

	# Verify world & meta restored
	check(loaded_game.keycards == ["lobby", "maintenance"], "loaded keycards restored")
	check(loaded_game.visited == ["lobby", "concourse", "maintenance"], "loaded visited areas restored")
	check(loaded_game.chef_quest == "active", "loaded chef_quest restored")
	check(loaded_game.wormhole.area == "maintenance", "loaded wormhole restored")
	check(loaded_game.hub_ground.size() == 1, "loaded hub ground items restored")
	check(loaded_game.buyback.size() == 1 and loaded_game.buyback[0].price == 45, "loaded buyback restored")

	# Verify equipment identity & backpack integration
	check(loaded_game.equipment.head.model >= 0, "head gear equipped")
	check(Backpack.worn(loaded_game.equipment.head, loaded_game.equipment), "worn() recognizes equipped head")
	check(loaded_game.equipment.head.grid_pos == Backpack.NOWHERE, "equipped gear grid_pos is NOWHERE")

	# Test 5: Two-handed heavy weapon equip preservation across save/load
	var heavy = Loot.make_item("weapon", 2, rng, false) # Collapse cannon (hands: 2)
	loaded_game.inventory.append(heavy)
	loaded_game.equip_item(loaded_game.inventory.size() - 1, "left")
	check(is_same(loaded_game.equipment.left, loaded_game.equipment.right), "heavy weapon equipped on both slots")

	SaveManager.save_game(loaded_game, TEST_SAVE_PATH)
	root.remove_child(loaded_game)
	loaded_game.queue_free()
	await process_frame

	var heavy_game = Game.new()
	root.add_child(heavy_game)
	heavy_game.sound_enabled = false
	heavy_game.set_physics_process(false)
	SaveManager.load_game(heavy_game, TEST_SAVE_PATH)
	await process_frame
	await physics_frame

	check(heavy_game.equipment.left.model == 2 and heavy_game.equipment.right.model == 2, "heavy weapon in left and right")
	check(is_same(heavy_game.equipment.left, heavy_game.equipment.right), "both slots reference exact same item dictionary")

	# Test 6: Tower floor state persistence
	heavy_game.travel_zone("lobby", false)
	await process_frame
	check(heavy_game.area == "lobby", "arrived in lobby")
	check(heavy_game.enemies.size() > 0, "lobby has enemies")

	# Kill the first enemy
	var target = heavy_game.enemies[0]
	heavy_game.hit_enemy(target, 9999.0)
	check(target.hp <= 0, "first enemy defeated")

	# Leave a drop
	var floor_drop_item = Loot.make_item("matrix", 0, rng, false)
	heavy_game.spawn_drop(Vector3(0.0, 0.0, 0.0), floor_drop_item)
	var drop_count = heavy_game.drops.size()
	check(drop_count > 0, "floor drop exists")

	# Save in tower
	SaveManager.save_game(heavy_game, TEST_SAVE_PATH)
	root.remove_child(heavy_game)
	heavy_game.queue_free()
	await process_frame

	# Reload into tower floor
	var tower_game = Game.new()
	root.add_child(tower_game)
	tower_game.sound_enabled = false
	tower_game.set_physics_process(false)
	SaveManager.load_game(tower_game, TEST_SAVE_PATH)
	await process_frame
	await physics_frame

	check(tower_game.area == "lobby", "reloaded directly into saved lobby area")
	check(tower_game.enemies[0].hp <= 0, "defeated enemy stays defeated")
	check(tower_game.drops.size() >= drop_count, "floor drop persisted on reload")

	# Test 7: Clean deletion
	root.remove_child(tower_game)
	tower_game.queue_free()
	check(SaveManager.delete_save(TEST_SAVE_PATH), "delete save returned true")
	check(not SaveManager.has_save(TEST_SAVE_PATH), "save file successfully deleted")

	print("SAVE SYSTEM CHECKS: %d / failures: %d" % [checks, failures])
	quit(failures)
