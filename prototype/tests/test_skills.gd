extends SceneTree

const Game = preload("res://scripts/main.gd")
const Skills = preload("res://scripts/skills.gd")
const Progression = preload("res://scripts/progression.gd")
const Loot = preload("res://scripts/loot.gd")
const SaveManager = preload("res://scripts/save_manager.gd")

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
	print("--- Running Arclight Skills & Controls Test Suite ---")
	
	# Test 1: Archetypes & Definitions Completeness
	check(Skills.ARCHETYPES.size() == 4, "4 core spell archetypes defined")
	check("projectile" in Skills.ARCHETYPES, "projectile archetype exists")
	check("nova" in Skills.ARCHETYPES, "nova archetype exists")
	check("hazard" in Skills.ARCHETYPES, "hazard archetype exists")
	check("overdrive" in Skills.ARCHETYPES, "overdrive archetype exists")
	
	for arch in Skills.ARCHETYPES:
		check(Skills.DEFINITIONS.has(arch), "DEFINITIONS has archetype: " + arch)
		var arch_dict = Skills.DEFINITIONS[arch]
		check(arch_dict.has("base_mana") and arch_dict.base_mana > 0, "%s has base_mana > 0" % arch)
		check(arch_dict.has("cooldown") and arch_dict.cooldown >= 0.0, "%s has valid cooldown" % arch)
		for aff in ["Cybernetic", "Visceral", "Draconic"]:
			check(arch_dict.has(aff), "archetype %s has affinity %s" % [arch, aff])
			var defn = arch_dict[aff]
			check(defn.has("name") and defn.name.length() > 0, "%s/%s has valid name" % [arch, aff])
			check(defn.has("desc") and defn.desc.length() > 0, "%s/%s has description" % [arch, aff])
			check(defn.has("element"), "%s/%s has element" % [arch, aff])
	
	# Test 2: Matrix Affinity Detection & Matching Item Count
	var rng = RandomNumberGenerator.new()
	rng.seed = 1337
	
	var equipment = {
		"head": Loot.make_item("head", 0, rng, false),
		"neck": Loot.make_item("neck", 0, rng, false),
		"barding": Loot.make_item("barding", 0, rng, false),
		"harness": Loot.make_item("harness", 0, rng, false),
		"matrix": Loot.make_item("matrix", 0, rng, false),
		"left": Loot.make_item("weapon", 0, rng, false),
		"right": Loot.make_item("weapon", 0, rng, false),
		"locomotion": Loot.make_item("locomotion", 0, rng, false)
	}
	
	check(Skills.get_matrix_affinity(equipment) == "Cybernetic", "base 0 matrix is Cybernetic")
	
	# Set Matrix affinity override to Visceral
	equipment.matrix.affinity = "Visceral"
	check(Skills.get_matrix_affinity(equipment) == "Visceral", "get_matrix_affinity returns Visceral for Visceral matrix")
	
	# Set Matrix affinity override to Draconic
	equipment.matrix.affinity = "Draconic"
	check(Skills.get_matrix_affinity(equipment) == "Draconic", "get_matrix_affinity returns Draconic for Draconic matrix")
	equipment.matrix.affinity = "Cybernetic"
	
	# Test 3: Affinity Resonance (4+ Matching Pieces)
	# Force all equipment to Visceral
	for slot in equipment:
		equipment[slot].affinity = "Visceral"
	var visceral_count = Skills.count_matching_affinity(equipment, "Visceral")
	check(visceral_count == 8, "all 8 slots counted as matching Visceral")
	check(Skills.has_resonance(equipment, "Visceral"), "8 matching pieces triggers resonance")
	
	# Set 4 pieces to Draconic, 4 to Cybernetic
	equipment.left.affinity = "Draconic"
	equipment.barding.affinity = "Draconic"
	equipment.head.affinity = "Draconic"
	equipment.locomotion.affinity = "Draconic" # 4 Draconic total
	equipment.harness.affinity = "Cybernetic"
	equipment.neck.affinity = "Cybernetic"
	equipment.right.affinity = "Cybernetic"
	equipment.matrix.affinity = "Cybernetic"
	
	check(Skills.count_matching_affinity(equipment, "Draconic") == 4, "4 pieces match Draconic")
	check(Skills.has_resonance(equipment, "Draconic"), "4 pieces triggers Draconic resonance")
	
	# Reduce Draconic count to 3
	equipment.left.affinity = "Cybernetic"
	check(Skills.count_matching_affinity(equipment, "Draconic") == 3, "3 pieces match Draconic")
	check(not Skills.has_resonance(equipment, "Draconic"), "3 pieces does NOT trigger resonance")
	
	# Test 4: Skill Data Resolution & Resonance Boosts
	# Draconic Fireball with resonance (4 Draconic pieces)
	equipment.left.affinity = "Draconic" # 4 Draconic now
	var resonant_skill = Skills.get_skill_data("projectile", equipment, 1)
	check(resonant_skill.affinity == "Draconic", "skill affinity morphed to Draconic")
	check(resonant_skill.name == "Fireball", "skill name resolved to Fireball")
	check(resonant_skill.resonance_active == true, "resonance_active is true on skill data")
	
	var base_defn = Skills.DEFINITIONS["projectile"]
	var base_mana = base_defn.base_mana
	var expected_mana = maxf(4.0, base_mana * 0.8)
	check(resonant_skill.mana_cost == expected_mana, "resonance applies 20% mana cost reduction")
	
	# Non-resonant Visceral Nova
	equipment.matrix.affinity = "Visceral"
	equipment.left.affinity = "Cybernetic"
	equipment.barding.affinity = "Cybernetic"
	equipment.head.affinity = "Cybernetic"
	equipment.locomotion.affinity = "Cybernetic"
	var non_res = Skills.get_skill_data("nova", equipment, 2)
	check(non_res.affinity == "Visceral", "nova morphed to Visceral")
	check(non_res.name == "Tendril Flail", "visceral nova name resolved")
	check(non_res.resonance_active == false, "resonance_active is false with 1 matching piece")
	
	# Test 5: Progression & Skill Point Allocation
	var prog = Progression.new()
	check(prog.skill_points == 0, "fresh character starts with 0 unspent skill points")
	
	# Gain XP to level up to Level 2
	prog.gain_xp(120)
	check(prog.level == 2, "gained enough XP to reach level 2")
	check(prog.skill_points == 1, "level up awarded +1 skill point")
	
	# Spend skill point
	check(prog.spend_skill(), "spend_skill consumed 1 point")
	check(prog.skill_points == 0, "skill_points is now 0")
	check(not prog.spend_skill(), "cannot spend when skill_points is 0")
	
	# Test 6: Keybindings System in Main Game
	var game = Game.new()
	game.run_seed = 54321
	game.sound_enabled = false
	root.add_child(game)
	await process_frame
	await physics_frame
	
	check(game.keybinds.has("attack"), "keybinds contains attack")
	check(game.keybinds.has("skills"), "keybinds contains skills")
	check(game.keybinds["skills"] == KEY_K, "skills defaults to KEY_K")
	check(game.get_key_name("skills") == "K", "get_key_name returns 'K'")
	
	# Rebind key
	game.rebind_key("skills", KEY_P)
	check(game.keybinds["skills"] == KEY_P, "skills rebound to KEY_P")
	check(game.get_key_name("skills") == "P", "get_key_name returns 'P'")
	
	# Reset keybinds
	game.reset_keybinds()
	check(game.keybinds["skills"] == KEY_K, "reset_keybinds restores default KEY_K")
	check(game.get_key_name("skills") == "K", "get_key_name returns 'K' after reset")
	
	# Test 7: In-Game Combat & Skill Casting
	game.begin()
	await process_frame
	await physics_frame
	
	check(is_instance_valid(game.hud.weapon_slot_button), "hud has weapon_slot_button")
	check(is_instance_valid(game.hud.skill_slot_button), "hud has skill_slot_button")
	check(game.hud.weapon_slot_button.visible, "weapon_slot_button is visible during gameplay")
	check(game.hud.skill_slot_button.visible, "skill_slot_button is visible during gameplay")
	
	# Unlock and assign projectile skill
	game.skills["projectile"] = 1
	game.assigned_skill = "projectile"
	game.skill_cooldowns["projectile"] = 0.0
	game.mana = 100.0
	
	# Cast skill at a target point
	game.cast_assigned_skill_at(Vector3(5.0, 0.0, 5.0))
	check(game.mana < 100.0, "mana was consumed by skill cast")
	check(game.skill_cooldowns["projectile"] > 0.0, "cooldown timer was initiated")
	
	# Test Nova casting
	game.skills["nova"] = 1
	game.assigned_skill = "nova"
	game.skill_cooldowns["nova"] = 0.0
	game.mana = 100.0
	game.cast_assigned_skill_at(Vector3.ZERO)
	check(game.skill_cooldowns["nova"] > 0.0, "nova cooldown initiated")
	
	# Test Hazard casting
	game.skills["hazard"] = 1
	game.assigned_skill = "hazard"
	game.skill_cooldowns["hazard"] = 0.0
	game.mana = 100.0
	game.cast_assigned_skill_at(Vector3(2.0, 0.0, 2.0))
	check(game.ground_hazards.size() == 1, "ground hazard was spawned")
	
	# Test Overdrive casting
	game.skills["overdrive"] = 1
	game.assigned_skill = "overdrive"
	game.skill_cooldowns["overdrive"] = 0.0
	game.mana = 100.0
	game.cast_assigned_skill_at(Vector3.ZERO)
	check(game.active_buffs.has("overdrive") and game.active_buffs["overdrive"] > 0.0, "active overdrive buff is active")
	
	# Test HUD Skills Panel
	check(is_instance_valid(game.hud.skills_panel), "skills_panel exists on HUD")
	check(not game.hud.skills_panel.visible, "skills_panel initially closed")
	game.toggle_skills()
	check(game.hud.skills_panel.visible, "skills_panel opened by toggle_skills()")
	game.toggle_skills()
	check(not game.hud.skills_panel.visible, "skills_panel closed by toggle_skills()")
	
	# Clean up
	game.queue_free()
	await process_frame
	
	print("--- Arclight Skills & Controls Test Results ---")
	print("Checks passed: %d / %d" % [checks - failures, checks])
	print("Failures: %d" % failures)
	
	if failures > 0:
		push_error("Skills and controls checks failed!")
		quit(1)
	else:
		print("ALL SKILLS AND CONTROLS TESTS PASSED.")
		quit(0)
