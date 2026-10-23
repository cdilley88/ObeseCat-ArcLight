class_name Skills
extends RefCounted

const Loot = preload("res://scripts/loot.gd")

## Diablo 1 style active skills morphed by equipped Matrix affinity and enhanced by 4+ matching set resonance.

const LIST = ["projectile", "nova", "hazard", "overdrive"]
const ARCHETYPES = LIST

const DEFINITIONS = {
	"projectile": {
		"id": "projectile",
		"tier": 1,
		"req_level": 1,
		"base_mana": 8.0,
		"cooldown": 0.55,
		"Cybernetic": {
			"name": "Plasma Orb",
			"element": "electromagnetic",
			"desc": "High-velocity ionized plasma sphere. Pierces electromagnetic energy.",
			"resonance_bonus": "Arcs secondary chain-lightning to adjacent target.",
			"color": Color("36d7ff")
		},
		"Visceral": {
			"name": "Acid Glob",
			"element": "radiation",
			"desc": "Heavy corrosive bio-acid lob that bursts upon impact.",
			"resonance_bonus": "Leaves a lingering pool of corrosive digestive acid.",
			"color": Color("9ee62b")
		},
		"Draconic": {
			"name": "Fireball",
			"element": "heat",
			"desc": "Blazing draconic fireball that detonates with fiery splash damage.",
			"resonance_bonus": "Ignites victims for residual burn damage over time.",
			"color": Color("ff6224")
		}
	},
	"nova": {
		"id": "nova",
		"tier": 2,
		"req_level": 3,
		"base_mana": 16.0,
		"cooldown": 1.4,
		"Cybernetic": {
			"name": "EMP Discharge",
			"element": "electromagnetic",
			"desc": "Radial electromagnetic pulse interrupting and stunning nearby machines.",
			"resonance_bonus": "Expands pulse radius by +40% and strips shields.",
			"color": Color("57b9ff")
		},
		"Visceral": {
			"name": "Tendril Flail",
			"element": "physical",
			"desc": "Lashing biological tentacles sweep 360 degrees around you, knocking back foes.",
			"resonance_bonus": "Knocks enemies back further and inflicts bleed.",
			"color": Color("b5ff3b")
		},
		"Draconic": {
			"name": "Dragon's Breath",
			"element": "heat",
			"desc": "Roaring forward cone of searing flame that sweeps across your frontal arc.",
			"resonance_bonus": "Triples cone range and leaves charred ground.",
			"color": Color("ff3d17")
		}
	},
	"hazard": {
		"id": "hazard",
		"tier": 3,
		"req_level": 6,
		"base_mana": 22.0,
		"cooldown": 3.2,
		"Cybernetic": {
			"name": "Nanite Minefield",
			"element": "electromagnetic",
			"desc": "Deploys a defensive perimeter of laser-triggered proximity micro-mines.",
			"resonance_bonus": "Mines detonate with cryogenic frost that slows survivors.",
			"color": Color("00e5ff")
		},
		"Visceral": {
			"name": "Mucous Mire",
			"element": "corruption",
			"desc": "Spits a thick puddle of toxic mucus that severely slows and dissolves incoming enemies.",
			"resonance_bonus": "Enemies walking through the mire suffer -50% armor.",
			"color": Color("7ad926")
		},
		"Draconic": {
			"name": "Magma Fissure",
			"element": "heat",
			"desc": "Rips open the concrete floor with molten lava that scorches anyone standing in it.",
			"resonance_bonus": "Fissure erupts with molten geysers dealing critical heat damage.",
			"color": Color("ff4900")
		}
	},
	"overdrive": {
		"id": "overdrive",
		"tier": 4,
		"req_level": 10,
		"base_mana": 28.0,
		"cooldown": 12.0,
		"duration": 7.0,
		"Cybernetic": {
			"name": "Kinetic Deflector",
			"element": "cryogenic",
			"desc": "Energy barrier diverting 45% of incoming damage to your Mana pool.",
			"resonance_bonus": "Generates continuous cryogenic aura chilling nearby attackers.",
			"color": Color("80d4ff")
		},
		"Visceral": {
			"name": "Parasitic Feast",
			"element": "corruption",
			"desc": "Biological bloodlust where all weapon strikes siphon 35% of damage dealt as Life.",
			"resonance_bonus": "Increases movement speed by +25% and attack speed by +20%.",
			"color": Color("aef745")
		},
		"Draconic": {
			"name": "Dragon Scales",
			"element": "heat",
			"desc": "Hardens skin into volcanic dragon scales granting +15 Armor and radiating contact heat.",
			"resonance_bonus": "Reflects 50% of melee damage back to attackers as fire.",
			"color": Color("ff8324")
		}
	}
}

static func get_matrix_affinity(equipment: Dictionary) -> String:
	if equipment.has("matrix") and not equipment.matrix.is_empty():
		var m_aff = str(equipment.matrix.get("affinity", "Cybernetic")).capitalize()
		if m_aff != "Cybernetic":
			return m_aff
	
	var draconic_count = count_matching_affinity(equipment, "Draconic")
	if draconic_count >= 4:
		return "Draconic"
	var visceral_count = count_matching_affinity(equipment, "Visceral")
	if visceral_count >= 4:
		return "Visceral"
		
	var cyber_count = count_matching_affinity(equipment, "Cybernetic")
	if draconic_count > cyber_count and draconic_count > visceral_count:
		return "Draconic"
	if visceral_count > cyber_count and visceral_count > draconic_count:
		return "Visceral"
		
	return "Cybernetic"

static func count_matching_affinity(equipment: Dictionary, affinity: String) -> int:
	var count = 0
	var target = affinity.capitalize()
	for slot in Loot.SLOTS:
		if equipment.has(slot) and not equipment[slot].is_empty():
			var item_aff = str(equipment[slot].get("affinity", "Cybernetic")).capitalize()
			if item_aff == target:
				count += 1
	return count

static func has_resonance(equipment: Dictionary, affinity: String = "") -> bool:
	var aff = affinity.capitalize() if affinity != "" else get_matrix_affinity(equipment)
	return count_matching_affinity(equipment, aff) >= 4

static func get_skill_data(skill_id: String, arg2, arg3 = null) -> Dictionary:
	if not DEFINITIONS.has(skill_id): return {}
	var equipment: Dictionary = arg2 if arg2 is Dictionary else (arg3 if arg3 is Dictionary else {})
	var rank: int = int(arg3) if arg2 is Dictionary else (int(arg2) if arg2 != null else 1)
	if rank <= 0: rank = 1
	var base = DEFINITIONS[skill_id]
	var aff = get_matrix_affinity(equipment)
	var variant = base.get(aff, base["Cybernetic"])
	var resonance = has_resonance(equipment, aff)
	
	var mana_cost = base.base_mana + (rank - 1) * 2.0
	if resonance:
		mana_cost = maxf(4.0, mana_cost * 0.8) # 20% mana discount with 4+ pieces
	
	var base_damage = 0.0
	match skill_id:
		"projectile":
			base_damage = 18.0 + rank * 8.0
		"nova":
			base_damage = 26.0 + rank * 11.0
		"hazard":
			base_damage = 10.0 + rank * 5.0 # per tick
		"overdrive":
			base_damage = 0.0
			
	if resonance and base_damage > 0:
		base_damage *= 1.25 # +25% damage with 4+ pieces
		
	return {
		"id": skill_id,
		"name": variant.name,
		"element": variant.element,
		"desc": variant.desc,
		"resonance_bonus": variant.resonance_bonus,
		"color": variant.color,
		"affinity": aff,
		"rank": rank,
		"tier": base.tier,
		"req_level": base.req_level,
		"mana_cost": mana_cost,
		"cooldown": base.cooldown,
		"duration": base.get("duration", 0.0),
		"damage": base_damage,
		"base_damage": base_damage,
		"resonance_active": resonance
	}
