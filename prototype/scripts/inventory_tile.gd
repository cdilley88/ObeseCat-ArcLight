extends Control
var hud
var index: int = -1
var equipped: bool = false
const CELL = 34

func setup(owner_hud, item_index: int, worn: bool = false):
	hud = owner_hud
	index = item_index
	equipped = worn
	var item: Dictionary = hud.game.inventory[index]
	mouse_entered.connect(func(): hud.hover_item(self))
	mouse_exited.connect(func(): hud.leave_item(self))
	mouse_filter = Control.MOUSE_FILTER_PASS
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var icon = TextureRect.new()
	icon.texture = load(item.icon)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon.offset_left = 5
	icon.offset_top = 4
	icon.offset_right = -5
	icon.offset_bottom = -5
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(icon)

func _draw():
	if not is_instance_valid(hud) or index >= hud.game.inventory.size(): return
	var item: Dictionary = hud.game.inventory[index]
	var color = hud.game.Loot.color(item)
	if hud.selection == index: color = Color("f2cc7e")
	draw_rect(Rect2(Vector2.ONE, size - Vector2.ONE * 2), Color("192a32"))
	draw_rect(Rect2(Vector2.ONE, size - Vector2.ONE * 2), color, false, 2 if hud.selection == index else 1)
	draw_line(Vector2(3, 3), Vector2(size.x - 4, 3), color.lightened(0.15))
	preload("res://scripts/rarity_fx.gd").paint(self,Rect2(Vector2.ONE,size-Vector2.ONE*2),item,hud.game.effects_enabled)

func _process(_delta):
	if is_visible_in_tree() and index >= 0 and index < hud.game.inventory.size() and hud.game.inventory[index].get("tier",0) >= 2: queue_redraw()

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			hud.select_item(index)
			if event.double_click: hud.activate_item(index)
			accept_event()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			hud.activate_item(index)
			accept_event()

func _get_drag_data(at: Vector2):
	hud.hide_item_card()
	if index < 0 or index >= hud.game.inventory.size(): return null
	var item: Dictionary = hud.game.inventory[index]
	var offset = Vector2i.ZERO if equipped else Vector2i(int(at.x / CELL), int(at.y / CELL))
	var preview = Control.new()
	var art = TextureRect.new()
	art.texture = load(item.icon)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.size = Vector2(item.width, item.height) * CELL
	art.position = -Vector2(offset) * CELL - Vector2.ONE * 17
	art.modulate.a = 0.8
	preview.add_child(art)
	set_drag_preview(preview)
	return {"kind": "inventory_item", "game": hud.game, "index": index, "item": item, "offset": offset}
