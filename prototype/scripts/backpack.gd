extends RefCounted
## Spatial inventory rules. Plans are validated before any ownership mutation.
const WIDTH = 12
const HEIGHT = 8
const NOWHERE = Vector2i(-1, -1)

static func footprint(item: Dictionary) -> Vector2i:
	return Vector2i(item.get("width", 1), item.get("height", 1))

static func worn(item: Dictionary, equipment: Dictionary) -> bool:
	for equipped in equipment.values():
		if is_same(item, equipped): return true
	return false

static func index_of(items: Array, item: Dictionary) -> int:
	for i in range(items.size()):
		if is_same(items[i], item): return i
	return -1

static func can_place(items: Array, equipment: Dictionary, item: Dictionary, pos: Vector2i, ignore: Dictionary = {}) -> bool:
	var size = footprint(item)
	if pos.x < 0 or pos.y < 0 or pos.x + size.x > WIDTH or pos.y + size.y > HEIGHT: return false
	var rect = Rect2i(pos, size)
	for other in items:
		if is_same(other, item) or is_same(other, ignore) or worn(other, equipment): continue
		var at: Vector2i = other.get("grid_pos", NOWHERE)
		if at != NOWHERE and rect.intersects(Rect2i(at, footprint(other))): return false
	return true

static func first_fit(items: Array, equipment: Dictionary, item: Dictionary, ignore: Dictionary = {}) -> Vector2i:
	for y in range(HEIGHT):
		for x in range(WIDTH):
			if can_place(items, equipment, item, Vector2i(x, y), ignore): return Vector2i(x, y)
	return NOWHERE

static func swap_plan(items: Array, equipment: Dictionary, incoming: Dictionary, target: String = "") -> Dictionary:
	var Loot = preload("res://scripts/loot.gd")
	if target == "":
		target = incoming.slot
		if target == "weapon":
			target = "left" if equipment.left.model < 0 or incoming.hands == 2 else "right"
	if not equipment.has(target): return {"ok": false}
	if incoming.slot == "weapon":
		if target not in ["left","right"]: return {"ok": false}
	elif incoming.slot != target: return {"ok": false}
	var next = equipment.duplicate()
	var displaced: Array = []
	var targets: Array = ["left","right"] if incoming.slot == "weapon" and incoming.hands == 2 else [target]
	for slot in targets:
		var old: Dictionary = next[slot]
		if old.model >= 0 and not is_same(old,incoming) and not Loot.contains_identity(displaced,old): displaced.append(old)
	for slot in next:
		if is_same(next[slot],incoming) or Loot.contains_identity(displaced,next[slot]): next[slot] = Loot.empty_item(slot)
	for slot in targets: next[slot] = incoming
	# Simulate only the displaced items; existing backpack positions never move.
	var occupied: Array = []
	for item in items:
		if is_same(item,incoming) or worn(item,equipment): continue
		occupied.append(item.duplicate(true))
	var placements: Array = []
	for item in displaced:
		var pos: Vector2i = incoming.get("grid_pos",NOWHERE)
		if not can_place(occupied,{},item,pos): pos = first_fit(occupied,{},item)
		if pos == NOWHERE: return {"ok": false}
		var copy = item.duplicate(true)
		copy.grid_pos = pos
		occupied.append(copy)
		placements.append({"item": item,"pos": pos})
	return {"ok": true,"equipment": next,"placements": placements}

static func arrange(items: Array, equipment: Dictionary) -> bool:
	# Work on a separate occupancy map; failure leaves the original layout intact.
	var indices: Array = []
	for i in range(items.size()):
		if not worn(items[i], equipment): indices.append(i)
	indices.sort_custom(func(a, b):
		var sa = footprint(items[a])
		var sb = footprint(items[b])
		return sa.x * sa.y > sb.x * sb.y)
	var occupied: Array[Rect2i] = []
	var plan: Dictionary = {}
	for i in indices:
		var size = footprint(items[i])
		var found = false
		for y in range(HEIGHT - size.y + 1):
			if found: break
			for x in range(WIDTH - size.x + 1):
				var rect = Rect2i(Vector2i(x, y), size)
				var clear = true
				for used in occupied:
					if rect.intersects(used): clear = false; break
				if clear:
					plan[i] = rect.position
					occupied.append(rect)
					found = true
					break
		if not found: return false
	for i in plan: items[i]["grid_pos"] = plan[i]
	return true

static func used_cells(items: Array, equipment: Dictionary) -> int:
	var count = 0
	for item in items:
		if not worn(item, equipment):
			var size = footprint(item)
			count += size.x * size.y
	return count
