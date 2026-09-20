extends RefCounted
## Cybernetic salvage laboratory. Numeric budgets are provisional.
const SLOTS = ["head", "neck", "barding", "harness", "matrix", "left", "right", "locomotion"]
const PARTS = ["Empty", "Capacitor", "Relay", "Ground"]
const RECIPE = ["Capacitor", "Relay", "Ground"]
const RARITIES = ["Basic", "Magic", "Magic Plus", "Rare", "Rare Plus", "Unique"]
const COLORS = [Color("e0e6e5"), Color("70df87"), Color("57ddeb"), Color("a98aff"), Color("f064cd"), Color("ffd16b")]
const ELEMENTS = ["heat","cryogenic","electromagnetic","radiation","gravity","corruption"]
const AFFINITIES = ["Cybernetic","Visceral","Draconic"]
const TYPES = {"physical": Color("e4c38c"), "radiation": Color("c5f16e"), "gravity": Color("7950c9"), "heat":Color("ff8a3c"), "cryogenic":Color("65e6ef"), "electromagnetic":Color("ffe46b"), "corruption": Color("df83ef")}
const Bonuses = preload("res://scripts/bonuses.gd")
const PRIMARY = ["damage", "strength", "dexterity", "vitality", "energy", "life", "mana"]
const SPECIAL = Bonuses.SPECIAL
const BASES = {
	"head": [
		{"name": "Combat helmet", "armor": 1.0, "size": Vector2i(2,2)},
		{"name": "Lead visor", "armor": 2.0, "radiation": 12.0, "size": Vector2i(2,2)},
		{"name":"Survey helmet", "armor":1.5, "mana":3.0, "size":Vector2i(2,2)},
		{"name":"Full Helm","affinity":"Draconic","visual":"full_helm","armor":2.0,"size":Vector2i(2,2)},
		{"name":"Frill","affinity":"Draconic","visual":"frill","armor":1.0,"size":Vector2i(2,2)},
		{"name":"Horns","affinity":"Draconic","visual":"horns","armor":1.5,"size":Vector2i(2,2)},
		{"name":"Ocular","affinity":"Visceral","visual":"ocular","armor":1.0,"size":Vector2i(2,2)},
		{"name":"Cranium","affinity":"Visceral","visual":"cranium","armor":1.0,"size":Vector2i(2,2)}],
	"neck": [
		{"name": "Signal amulet", "mana": 5.0, "size": Vector2i(1,1)},
		{"name": "Anchor pendant", "gravity": 12.0, "size": Vector2i(1,2)},
		{"name":"Relay amulet", "life":5.0, "size":Vector2i(1,1)},
		{"name":"Telemetry pendant", "mana":5.0, "size":Vector2i(1,2)}],
	"barding": [
		{"name": "Field plating", "armor": 2.0, "size": Vector2i(2,3)},
		{"name": "Blast carapace", "armor": 4.0, "speed": -0.2, "size": Vector2i(3,3)},
		{"name":"Cyber Bracing", "armor":1.5, "size":Vector2i(2,3)},
		{"name":"Conductive Mesh", "armor":1.2, "electromagnetic":5.0, "size":Vector2i(2,3)},
		{"name":"Interface Suit", "armor":0.8, "size":Vector2i(2,2)},
		{"name":"Impact Padding", "armor":1.0, "size":Vector2i(2,2)},
		{"name":"Breast Plate","affinity":"Draconic","visual":"breast_plate","armor":3.0,"size":Vector2i(2,3)},
		{"name":"Scale Coat","affinity":"Draconic","visual":"scale_coat","armor":2.0,"size":Vector2i(2,3)},
		{"name":"Spines","affinity":"Draconic","visual":"spines","armor":2.5,"size":Vector2i(3,3)}],
	"harness": [
		{"name": "Cyber Harness", "life": 5.0, "size": Vector2i(2,1)},
		{"name": "Insulated belt", "corruption": 12.0, "size": Vector2i(2,1)}],
	"matrix": [
		{"name": "Targeting matrix", "attack_speed": 5.0, "size": Vector2i(2,2)},
		{"name": "Circuit matrix", "size": Vector2i(1,3)}],
	"weapon": [
		{"name": "Laser carbine", "damage": 12.0, "period": 0.52, "windup": 0.12, "reach": 6.0, "type": "radiation", "size": Vector2i(1,3)},
		{"name": "Phase blade", "attack": "swipe", "damage": 16.0, "period": 0.58, "windup": 0.15, "reach": 2.3, "type": "corruption", "size": Vector2i(1,3)},
		{"name": "Collapse cannon", "damage": 30.0, "period": 1.65, "windup": 0.48, "reach": 7.5, "hands": 2, "type": "gravity", "size": Vector2i(2,4)},
		{"name": "Reactor launcher", "attack": "missile", "damage": 42.0, "period": 1.85, "windup": 0.58, "reach": 7.0, "hands": 2, "splash": 2.1, "type": "radiation", "size": Vector2i(2,4)},
		{"name":"Phase cleaver", "attack":"cleave", "damage":38.0, "period":1.45, "windup":0.42, "reach":3.2, "hands":2, "type":"corruption", "size":Vector2i(2,4)},
		{"name":"Claws","affinity":"Draconic","visual":"claws","attack":"swipe","damage":16.0,"period":0.58,"windup":0.15,"reach":2.3,"type":"heat","size":Vector2i(1,3)},
		{"name":"Fangs","affinity":"Draconic","visual":"fangs","attack":"cleave","hands":2,"damage":38.0,"period":1.45,"windup":0.42,"reach":3.2,"type":"heat","size":Vector2i(2,4)},
		{"name":"Breath","affinity":"Draconic","visual":"breath","attack":"breath","hands":2,"damage":30.0,"period":1.65,"windup":0.48,"reach":5.5,"type":"heat","size":Vector2i(2,4)},
		{"name":"Wand","affinity":"Draconic","visual":"wand","damage":12.0,"period":0.52,"windup":0.12,"reach":6.0,"type":"heat","size":Vector2i(1,3)},
		{"name":"Tentacle","affinity":"Visceral","visual":"tentacle","attack":"swipe","damage":16.0,"period":0.58,"windup":0.15,"reach":2.3,"type":"corruption","size":Vector2i(1,3)},
		{"name":"Tail","affinity":"Visceral","visual":"tail","attack":"cleave","hands":2,"damage":38.0,"period":1.45,"windup":0.42,"reach":3.2,"type":"corruption","size":Vector2i(2,4)},
		{"name":"Acid Spray","affinity":"Visceral","visual":"acid_spray","attack":"breath","hands":2,"damage":30.0,"period":1.65,"windup":0.48,"reach":5.5,"type":"radiation","size":Vector2i(2,4)},
		{"name":"Quills","affinity":"Visceral","visual":"quills","attack":"quills","damage":12.0,"period":0.52,"windup":0.12,"reach":6.0,"type":"corruption","size":Vector2i(1,3)}],
	"locomotion": [
		{"name": "Paw servos", "speed": 0.15, "mode": "paws", "size": Vector2i(2,2)},
		{"name": "Crawler treads", "speed": -0.45, "reduction": 8.0, "mode": "treads", "size": Vector2i(3,2)},
		{"name": "Spider struts", "speed": 0.35, "dodge": 8.0, "mode": "spider", "size": Vector2i(3,3)},
		{"name": "Hover skirt", "speed": 0.75, "armor": -1.0, "mode": "hover", "size": Vector2i(3,2)},
		{"name":"Wings","affinity":"Draconic","visual":"wings","speed":0.35,"mode":"wings","size":Vector2i(3,3)},
		{"name":"Wyrm Legs","affinity":"Draconic","visual":"wyrm_legs","speed":0.15,"mode":"wyrm","size":Vector2i(3,2)},
		{"name":"Greaves","affinity":"Draconic","visual":"greaves","armor":1.0,"mode":"greaves","size":Vector2i(2,2)}]
}

static func make_item(slot: String, base: int, rng: RandomNumberGenerator, rolled: bool = true, level: int = 1, tier: int = -1) -> Dictionary:
	var kind = "weapon" if slot in ["left", "right", "weapon"] else slot
	var item = {"slot": kind, "model": base, "damage": 0.0, "armor": 0.0, "speed": 0.0, "signature": false, "sockets": [], "hands": 1, "affixes": [], "level": maxi(1,level), "tier": 0, "affinity":"Cybernetic"}
	item.merge(BASES[kind][base], true)
	item["width"] = item.size.x
	item["height"] = item.size.y
	item.erase("size")
	item["grid_pos"] = Vector2i(-1,-1)
	item["icon"] = "res://assets/items/%s_%s.svg" % [item.affinity.to_lower(),item.visual] if item.has("visual") else "res://assets/items/%s_%d.svg" % [kind,base]
	if kind == "matrix" and base == 1: item.sockets = ["Empty", "Empty", "Empty"]
	item.tier = clampi(tier,0,4) if tier >= 0 else (roll_tier(rng,level) if rolled else 0)
	# White bases do not scale with item level; bonuses carry later progression.
	var count: int = [0,1,2,3,3][item.tier]
	var used: Array = []
	for i in range(count):
		var rare_bonus = i == 2
		var key: String = Bonuses.pick(rng,item.tier,rare_bonus,used)
		used.append(key)
		var budget = (1.0 + minf(level,12)*0.18) * [0.0,1.0,1.8,2.3,3.1][item.tier] * rng.randf_range(0.85,1.15)
		if item.tier == 2 and i == 1: budget *= 0.4
		var value = snappedf(budget * Bonuses.scale(key), 0.1)
		item[key] = float(item.get(key,0)) + value
		item.affixes.append({"key": key, "value": value, "role": "rare" if rare_bonus else ("secondary" if item.tier == 2 and i == 1 else "primary")})
	if rolled and kind == "weapon":
		item.type = ELEMENTS[rng.randi_range(0,ELEMENTS.size()-1)]
		item.name = item.type.capitalize()+" "+item.name
	item["affix"] = RARITIES[item.tier]
	return item

static func bonus_scale(key: String) -> float:
	return Bonuses.scale(key)

static func roll_tier(rng: RandomNumberGenerator, level: int, discovery: float = 0.0) -> int:
	var roll = rng.randf()*100.0
	var weights = [45.0,38.0,13.0,3.5,0.5] if level <= 3 else ([15.0,35.0,30.0,19.0,1.0] if level < 8 else [5.0,15.0,25.0,53.0,2.0])
	var bonus = clampf(discovery,0,300)/100.0
	var total = 0.0
	for tier in range(5):
		weights[tier] *= 1.0+bonus*tier/4.0
		total += weights[tier]
	roll *= total/100.0
	for tier in range(5):
		roll -= weights[tier]
		if roll < 0: return tier
	return 4

static func salvage(rng: RandomNumberGenerator, level: int, affinity: String = "") -> Dictionary:
	var kinds = BASES.keys()
	var kind: String = kinds[rng.randi_range(0,kinds.size()-1)]
	return make_item(kind,pick_base(rng,kind,affinity),rng,true,level)

static func signature_item(rng: RandomNumberGenerator) -> Dictionary:
	var item = make_item("weapon",0,rng,false)
	item.name = "SPLIT DECISION"
	item.damage = 9.0
	item.signature = true
	item.affix = "Signature / experimental"
	return item

static func empty_item(slot: String) -> Dictionary:
	return {"slot": slot, "name": "Empty " + slot, "model": -1, "damage": 0.0, "armor": 0.0, "speed": 0.0, "signature": false, "sockets": [], "affix": "Unequipped", "hands": 1}

static func circuit_active(item: Dictionary) -> bool:
	return item.get("sockets",[]) == RECIPE

static func color(item: Dictionary) -> Color:
	return Color("edc476") if item.get("signature",false) else COLORS[item.get("tier",0)]

static func stats(equipment: Dictionary) -> Dictionary:
	var result = {"damage": 0.0, "armor": 0.0, "speed": 3.5, "circuit": false, "attack_speed": 0.0, "reduction": 0.0, "heat":0.0,"cryogenic":0.0,"electromagnetic":0.0,"radiation": 0.0, "gravity": 0.0, "corruption": 0.0, "dodge": 0.0, "life": 0.0, "mana": 0.0, "strength": 0.0, "dexterity": 0.0, "vitality": 0.0, "energy": 0.0}
	for key in Bonuses.ALL: if not result.has(key): result[key] = 0.0
	result["flat_heat"] = 0.0
	var seen: Array = []
	for item in equipment.values():
		if item.model < 0 or contains_identity(seen,item): continue
		seen.append(item)
		for key in result:
			if key == "circuit" or (key == "damage" and item.slot == "weapon"): continue
			result[key] += float(item.get(key,0))
		if circuit_active(item): result.circuit = true
		else:
			for part in item.get("sockets",[]):
				match part:
					"Capacitor": result.damage += 2.0
					"Relay": result.speed += 0.15
					"Ground": result.armor += 1.0
	result["bonus_damage"] = result.damage
	var weapons = equipped_weapons(equipment)
	var damage = 4.0 if weapons.is_empty() else 0.0
	for item in weapons: damage += float(item.damage) / weapons.size()
	result.damage += damage
	result.speed = clampf(result.speed,1.5,6.0)
	result.attack_speed = clampf(result.attack_speed,0,60)
	result.reduction = clampf(result.reduction,0,50)
	for key in ELEMENTS: result[key] = clampf(result[key],0,75)
	for key in Bonuses.ALL:
		if key.begins_with("guard_"): result[key] = clampf(result[key],0,50)
	for key in ["melee_arc","projectile_range","explosion_radius"]: result[key] = clampf(result[key],0,100)
	return result

static func contains_identity(items: Array, item: Dictionary) -> bool:
	for other in items:
		if is_same(other,item): return true
	return false

static func equipped_weapons(equipment: Dictionary) -> Array:
	var result: Array = []
	for slot in ["left","right"]:
		var item: Dictionary = equipment[slot]
		if item.model >= 0 and not contains_identity(result,item): result.append(item)
	return result

static func label(item: Dictionary) -> String:
	return "%s · %s" % [item.affix,item.name]

static func describe(item: Dictionary) -> String:
	var line = ""
	if item.slot == "weapon":
		line = "%s · %s\n%.1f dmg / %.2fs / %.1fm reach\n" % ["TWO SLOTS" if item.hands == 2 else "ONE SLOT",item.type.capitalize(),item.damage,item.period,item.reach]
		if item.type == "radiation": line += "Radiation: damage over time and one local spread.\n"
		if item.type == "gravity": line += "Collapse: flat damage + capped 3% maximum Life.\n"
		if item.type == "corruption": line += "50-150% damage; weakens damage/armor for 3s.\n"
		if item.get("splash",0) > 0: line += "Missile: full damage within explosion radius.\n" if item.get("attack","") == "missile" else "Blast: nearby targets take 50%.\n"
	else:
		for key in ["armor","life","mana","speed","attack_speed","reduction","heat","cryogenic","electromagnetic","radiation","gravity","corruption","dodge"]:
			if item.get(key,0) != 0: line += "%s %+.1f%s   " % [key.capitalize(),item[key],"%" if key in SPECIAL and key != "speed" or key == "dodge" else ""]
		line += "\n"
	for mod in item.get("affixes",[]): line += "%s: +%.1f %s\n" % [mod.role.capitalize(),mod.value,mod.key.replace("_"," ")]
	if item.get("tier",0) == 0: line += "Base stats only; no random modifiers.\n"
	if item.get("signature",false): line += "One extra target at 70%; no chains.\n"
	if not item.sockets.is_empty(): line += "3 removable Circuit sockets."
	return line.strip_edges()

static func chefbot_hat() -> Dictionary:
	var rng = RandomNumberGenerator.new()
	var item = make_item("head",0,rng,false)
	item.merge({"unique_id":"chefbot_hat","name":"ChefBot Hat","model":3,"tier":5,"affix":"Unique","armor":2.0,"heat":20.0,"flat_heat":5.0,"strength":3.0,"dexterity":3.0,"vitality":3.0,"energy":3.0,"life":-15.0,"icon":"res://assets/items/chefbot_hat.svg"},true)
	return item

# Select an affinity before a base so large catalogs cannot dominate smaller families.
static func pick_base(rng: RandomNumberGenerator, kind: String, preferred: String = "") -> int:
	var pools = {}
	for i in range(BASES[kind].size()):
		var family: String = BASES[kind][i].get("affinity","Cybernetic")
		if not pools.has(family): pools[family] = []
		pools[family].append(i)
	var families: Array = pools.keys()
	var family: String
	if families.size() > 1 and pools.has(preferred):
		if rng.randf() < 0.85: family = preferred
		else:
			families.erase(preferred)
			family = families[rng.randi_range(0,families.size()-1)]
	else: family = families[rng.randi_range(0,families.size()-1)]
	var pool: Array = pools[family]
	return pool[rng.randi_range(0,pool.size()-1)]
