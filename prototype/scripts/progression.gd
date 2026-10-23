extends RefCounted
## Temporary attribute formulas, isolated for future universe-specific redesign.
const ATTRIBUTES = ["strength", "dexterity", "vitality", "energy"]
const POINTS_PER_LEVEL = 5
var level: int = 1
var xp: int = 0
var points: int = 0
var skill_points: int = 0
var attributes: Dictionary = {"strength": 10, "dexterity": 10, "vitality": 10, "energy": 10}

func required_xp() -> int:
	return level * 50

func gain_xp(amount: int) -> int:
	if amount <= 0: return 0
	xp += amount
	var gained = 0
	while xp >= required_xp():
		xp -= required_xp()
		level += 1
		points += POINTS_PER_LEVEL
		skill_points += 1
		gained += 1
	return gained

func spend_skill() -> bool:
	if skill_points <= 0: return false
	skill_points -= 1
	return true

func spend(attribute: String) -> bool:
	if points <= 0 or not ATTRIBUTES.has(attribute): return false
	attributes[attribute] += 1
	points -= 1
	return true

func derive(gear: Dictionary) -> Dictionary:
	var result = gear.duplicate()
	var total = attributes.duplicate()
	for key in ATTRIBUTES: total[key] += gear.get(key,0)
	result.damage += (total.strength - 10) * 0.5
	result["bonus_damage"] = gear.get("bonus_damage",0) + (total.strength-10)*0.5
	result.armor += (total.dexterity - 10) * 0.2
	result["max_life"] = 100.0 + gear.get("life",0) + (total.vitality - 10) * 5.0
	result["max_mana"] = 50.0 + gear.get("mana",0) + (total.energy - 10) * 5.0
	result["mana_regen"] = 3.0 + gear.get("mana_regen",0) + (total.energy - 10) * 0.1
	result.damage = maxf(1,result.damage)
	return result
