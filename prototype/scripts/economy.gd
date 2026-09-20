extends RefCounted
const Loot = preload("res://scripts/loot.gd")

static func value(item: Dictionary) -> int:
	return 8 + item.width*item.height*2 + item.get("tier",0)*18 + mini(item.get("level",1),12)*2

static func stock(seed_value: int, level: int) -> Dictionary:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	var result = {"weapons":[],"armor":[]}
	for kind in Loot.BASES:
		for base in range(Loot.BASES[kind].size()):
			var item = Loot.make_item(kind,base,rng,false,level)
			if kind == "weapon": result.weapons.append(item)
			else: result.armor.append(item)
	for kind in ["weapon","barding"]:
		if kind == "weapon": result.weapons.append(Loot.make_item(kind,0,rng,true,level,1))
		else: result.armor.append(Loot.make_item(kind,0,rng,true,level,1))
	return result

static func price(item: Dictionary) -> int:
	return value(item)*3
