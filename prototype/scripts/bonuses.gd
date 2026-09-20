extends RefCounted
## Central affix catalog. Weights and caps are provisional playtest values.
const COMMON = ["damage", "strength", "dexterity", "vitality", "energy", "life", "mana"]
const SPECIAL = ["speed", "attack_speed", "reduction", "heat", "cryogenic", "electromagnetic", "radiation", "gravity", "corruption", "life_regen", "mana_regen", "flat_reduction", "elemental_reduction", "item_discovery", "silicon_discovery", "melee_arc", "projectile_range", "explosion_radius", "guard_cybernetic", "slayer_cybernetic", "guard_visceral", "slayer_visceral", "guard_draconic", "slayer_draconic", "damage_heat", "damage_cryogenic", "damage_electromagnetic", "damage_radiation", "damage_gravity", "damage_corruption"]
const ALL = COMMON + SPECIAL

static func pick(rng: RandomNumberGenerator, tier: int, rare: bool, used: Array) -> String:
	var choices: Array = []
	var weights: Array = []
	var total = 0.0
	for key in (SPECIAL if rare else ALL):
		if key in used: continue
		var weight = 8.0 if key in COMMON else [0.0,0.4,1.0,1.6,2.2][tier]
		if key in ["speed","attack_speed","heat","cryogenic","electromagnetic","radiation","gravity","corruption"]: weight *= 2.0
		choices.append(key)
		weights.append(weight)
		total += weight
	var roll = rng.randf()*total
	for i in range(choices.size()):
		roll -= weights[i]
		if roll <= 0: return choices[i]
	return choices.back()

static func scale(key: String) -> float:
	if key in ["life","mana"]: return 5.0
	if key == "speed": return 0.1
	if key in ["life_regen","mana_regen"]: return 0.15
	if key in ["flat_reduction","elemental_reduction"]: return 0.25
	if key in COMMON: return 1.0
	return 2.0

static func percent(key: String) -> bool:
	return key in SPECIAL and key not in ["speed","life_regen","mana_regen","flat_reduction","elemental_reduction"]

static func label(key: String) -> String:
	if key in ["heat","cryogenic","electromagnetic","radiation","gravity","corruption"]: return key.capitalize()+" resistance"
	if key == "speed": return "Movement speed"
	if key.begins_with("damage_"): return key.trim_prefix("damage_").capitalize()+" damage"
	if key.begins_with("guard_"): return "Less damage from "+key.trim_prefix("guard_").capitalize()
	if key.begins_with("slayer_"): return "Damage to "+key.trim_prefix("slayer_").capitalize()
	return {"flat_reduction":"Damage reduced by", "elemental_reduction":"Elemental damage reduced by", "life_regen":"Life regeneration / sec", "mana_regen":"Mana regeneration / sec", "melee_arc":"Melee reach / arc", "projectile_range":"Projectile range", "explosion_radius":"Explosion radius", "item_discovery":"Item Discovery", "silicon_discovery":"Silicon Discovery"}.get(key,key.replace("_"," ").capitalize())

static func silicon(base: int, discovery: float) -> int:
	return int(floor(base*(1.0+clampf(discovery,0,300)/100.0)))
