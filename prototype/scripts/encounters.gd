extends RefCounted
## Encounter types and spawn regions are separate from floor geometry.
const Randomness = preload("res://scripts/world_random.gd")
const TYPES = {
"security":{"affinity":"Cybernetic","model":"sentry","behavior":"attacking"},
"supervisor":{"affinity":"Cybernetic","model":"warden","behavior":"attacking"},
"laser_turret":{"affinity":"Cybernetic","model":"laser","behavior":"stationary","weapon":"laser","reach":7.0,"period":1.5,"windup":0.55,"element":"electromagnetic"},
"laser_patrol":{"affinity":"Cybernetic","model":"laser","behavior":"patrolling","weapon":"laser","reach":6.0,"period":1.7,"windup":0.6,"element":"radiation"},
"rocket_sentry":{"affinity":"Cybernetic","model":"rocket","behavior":"patrolling","weapon":"rocket","reach":8.0,"period":2.8,"windup":1.0,"element":"heat"},
"blade_chaser":{"affinity":"Cybernetic","model":"blade","behavior":"chasing","weapon":"blade","reach":2.3,"period":1.3,"windup":0.5,"element":"corruption"},
"chefbot":{"affinity":"Cybernetic","model":"chef","behavior":"chasing","weapon":"rocket","reach":7.5,"period":2.3,"windup":0.85,"element":"heat"},
"obesecat":{"affinity":"Cybernetic","model":"obesecat","behavior":"chasing","weapon":"rocket","reach":8.0,"period":1.9,"windup":0.9,"element":"heat"}}

# Future floor chunks supply these region descriptors instead of global room coordinates.
static func regions(bounds: Rect2, main_floor: bool) -> Array:
	var points = [Vector2(-9,10),Vector2(9,9),Vector2(-14,1),Vector2(14,-6),Vector2(-8,-9),Vector2(8,-10)] if main_floor else [Vector2(-7,5),Vector2(7,5),Vector2(-7,-4),Vector2(7,-4)]
	var result: Array = []
	for point in points:
		result.append({"region":Rect2(point-Vector2(2.5,2.5),Vector2(5,5)).intersection(bounds.grow(-2)),"pool":["security"],"boss":false})
	result.append({"region":Rect2(Vector2(-2,bounds.position.y+4),Vector2(4,3)),"pool":["supervisor"],"boss":true})
	return result
static func plan(seed_value: int, sortie: int, area: String, descriptors: Array, walkable: Callable) -> Array:
	var result: Array = []
	for index in range(descriptors.size()):
		var descriptor: Dictionary = descriptors[index]
		var rng = Randomness.stream(seed_value,sortie,area,"placement",index)
		var rect: Rect2 = descriptor.region
		var candidates: Array = []
		# Half-unit cell centers also match the navigation raster.
		for x in range(int(ceil(rect.position.x*2)),int(floor(rect.end.x*2))):
			for z in range(int(ceil(rect.position.y*2)),int(floor(rect.end.y*2))):
				var pos = Vector3(x*0.5+0.25,0,z*0.5+0.25)
				if not walkable.call(pos): continue
				var separated = true
				for other in result:
					if other.pos.distance_to(pos) < 1.8: separated = false
				if separated: candidates.append(pos)
		if candidates.is_empty():
			push_error("Encounter region has no reachable spawn: "+area+" / "+str(index))
			continue
		var chosen = candidates[rng.randi_range(0,candidates.size()-1)]
		var type_id: String = descriptor.pool[rng.randi_range(0,descriptor.pool.size()-1)]
		result.append({"pos":chosen,"type":type_id,"boss":descriptor.boss,"index":index})
	return result
