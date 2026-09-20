extends Control
const Tile = preload("res://scripts/inventory_tile.gd")
var hud
var slot: String

func setup(owner_hud, slot_name: String):
	hud = owner_hud
	slot = slot_name
	custom_minimum_size = Vector2(96, 68)
	size = custom_minimum_size

func refresh():
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var label = Label.new()
	label.text = slot.to_upper()
	if slot in ["left","right"] and hud.game.equipment[slot].get("hands",1) == 2: label.text += " / 2H"
	label.add_theme_font_size_override("font_size", 12)
	label.modulate = Color("e0bc7c")
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	var index: int = hud.game.Backpack.index_of(hud.game.inventory, hud.game.equipment[slot])
	if index >= 0:
		var tile = Tile.new()
		add_child(tile)
		tile.position = Vector2(0, 19)
		tile.size = Vector2(96, 47)
		tile.setup(hud, index, true)
	queue_redraw()

func _draw():
	draw_rect(Rect2(0, 19, 96, 47), Color("192b32"))
	draw_rect(Rect2(0, 19, 96, 47), Color("478b78"), false)
	if hud and hud.game.equipment[slot].model < 0:
		draw_line(Vector2(47, 47), Vector2(72, 47), Color("486066"), 2)
		draw_line(Vector2(64, 39), Vector2(64, 55), Color("486066"), 2)

func _can_drop_data(_at: Vector2, data) -> bool:
	return hud.inventory_grid.valid_data(data) and hud.game.can_equip_item(data.index, slot)

func _drop_data(at: Vector2, data):
	if _can_drop_data(at, data):
		hud.game.equip_item(data.index,slot)
		hud.selection = data.index
		hud.refresh_inventory()
