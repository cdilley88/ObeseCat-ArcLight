extends RefCounted
## Versioned independent streams: combat draws cannot perturb rewards/layout.
const VERSION = 1
static func fresh(previous: int = -1) -> int:
	var entropy = RandomNumberGenerator.new()
	entropy.randomize()
	var value = entropy.randi_range(1,2147483646)
	while value == previous: value = entropy.randi_range(1,2147483646)
	return value
static func derive(seed_value: int, sortie: int, area: String, channel: String, index: int = 0) -> int:
	return int(("v%d/%d/%d/%s/%s/%d" % [VERSION,seed_value,sortie,area,channel,index]).hash())
static func stream(seed_value: int, sortie: int, area: String, channel: String, index: int = 0) -> RandomNumberGenerator:
	var rng = RandomNumberGenerator.new()
	rng.seed = derive(seed_value,sortie,area,channel,index)
	return rng
