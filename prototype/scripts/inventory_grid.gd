extends Control
const Bag = preload("res://scripts/backpack.gd")
const Tile = preload("res://scripts/inventory_tile.gd")
const CELL = 34
var hud

func setup(owner_hud):
	hud = owner_hud
	custom_minimum_size = Vector2(Bag.WIDTH, Bag.HEIGHT) * CELL
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_STOP

func refresh():
	for child in get_children():
		remove_child(child)
		child.queue_free()
	for i in range(hud.game.inventory.size()):
		var item: Dictionary = hud.game.inventory[i]
		if Bag.worn(item, hud.game.equipment): continue
		var pos: Vector2i = item.get("grid_pos", Bag.NOWHERE)
		if pos == Bag.NOWHERE: continue
		var tile = Tile.new()
		add_child(tile)
		tile.position = Vector2(pos) * CELL
		tile.size = Vector2(Bag.footprint(item)) * CELL
		tile.setup(hud, i)
	queue_redraw()

func _draw():
	for y in range(Bag.HEIGHT):
		for x in range(Bag.WIDTH):
			var cell = Rect2(Vector2(x, y) * CELL, Vector2.ONE * (CELL - 1))
			draw_rect(cell, Color("111e26") if (x + y) % 2 else Color("15232b"))
			draw_rect(cell, Color("33474d"), false)
	var data = get_viewport().gui_get_drag_data()
	if valid_data(data):
		var at = get_local_mouse_position()
		var cell = destination(at, data)
		if Rect2(Vector2.ZERO, size).has_point(at):
			var ok = _can_drop_data(at, data)
			var item: Dictionary = hud.game.inventory[data.index]
			var r = Rect2(Vector2(cell) * CELL, Vector2(Bag.footprint(item)) * CELL)
			draw_rect(r, Color(0.3, 0.95, 0.6, 0.24) if ok else Color(1, 0.25, 0.3, 0.25))
			draw_rect(r, Color("93efb4") if ok else Color("fa7b81"), false, 2)

func _process(_delta):
	if is_visible_in_tree(): queue_redraw()

func valid_data(data) -> bool:
	return data is Dictionary and data.get("kind") == "inventory_item" and data.get("game") == hud.game and data.get("index", -1) >= 0 and data.index < hud.game.inventory.size() and is_same(data.get("item"), hud.game.inventory[data.index])

func destination(at: Vector2, data: Dictionary) -> Vector2i:
	return Vector2i(floori(at.x / CELL), floori(at.y / CELL)) - data.offset

func _can_drop_data(at: Vector2, data) -> bool:
	if not valid_data(data): return false
	return Bag.can_place(hud.game.inventory, hud.game.equipment, hud.game.inventory[data.index], destination(at, data))

func _drop_data(at: Vector2, data):
	if _can_drop_data(at, data):
		hud.game.move_inventory_item(data.index, destination(at, data))
		hud.selection = data.index
		hud.refresh_inventory()
