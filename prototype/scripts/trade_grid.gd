extends Control
## Read-only spatial display; transactions remain explicit menu actions.
const Loot = preload("res://scripts/loot.gd")
const CELL = 28
var menu
var origin = "stock"
var columns = 10
var entries: Array = []
var pages: Array = []
var page = 0
var hovered = -1
var selected = -1
var art: Dictionary = {}

func setup(owner_menu, items: Array, kind: String):
	menu = owner_menu
	origin = kind
	columns = 12 if kind == "bag" else 10
	entries = items
	custom_minimum_size = Vector2(columns*CELL,8*CELL)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_exited.connect(func(): hovered = -1; menu.preview_selected(); queue_redraw())
	pages = [[]]
	for i in range(items.size()):
		var item: Dictionary = items[i].item if kind == "buyback" else items[i]
		if not art.has(item.icon):
			var texture = load(item.icon)
			art[item.icon] = {"texture":texture,"region":texture.get_image().get_used_rect()}
		var shape = Vector2i(item.width,item.height)
		var at: Vector2i = item.grid_pos if kind == "bag" else Vector2i(-1,-1)
		if kind != "bag":
			at = first_fit(pages[-1],shape)
			if at.x < 0:
				pages.append([])
				at = first_fit(pages[-1],shape)
		pages[-1].append({"index":i,"rect":Rect2i(at,shape),"item":item})

func first_fit(placed: Array, shape: Vector2i) -> Vector2i:
	for y in range(9-shape.y):
		for x in range(columns+1-shape.x):
			var rect = Rect2i(Vector2i(x,y),shape)
			var free = true
			for tile in placed:
				if rect.intersects(tile.rect): free = false; break
			if free: return Vector2i(x,y)
	return Vector2i(-1,-1)

func _draw():
	draw_rect(Rect2(Vector2.ZERO,custom_minimum_size),Color("10191f"))
	for y in range(8):
		for x in range(columns):
			var rect = Rect2(Vector2(x,y)*CELL+Vector2.ONE,Vector2.ONE*(CELL-2))
			draw_rect(rect,Color("26373b") if (x+y)%2 == 0 else Color("202e34"))
			draw_rect(rect,Color("405056"),false)
	for tile in pages[page]:
		var rect = Rect2(Vector2(tile.rect.position)*CELL+Vector2.ONE,Vector2(tile.rect.size)*CELL-Vector2.ONE*2)
		var color = Loot.color(tile.item)
		var active = selected == tile.index or hovered == tile.index
		draw_rect(rect,Color("3e514d") if active else Color("15242b"))
		draw_rect(rect,Color("f2cf86") if active else color,false,2 if active else 1)
		preload("res://scripts/rarity_fx.gd").paint(self,rect,tile.item,menu.game.effects_enabled)
		var sprite: Dictionary = art[tile.item.icon]
		var available = rect.grow(-3)
		var source_size = Vector2(sprite.region.size)
		var scale = minf(available.size.x/source_size.x,available.size.y/source_size.y)
		var art_size = source_size*scale
		draw_texture_rect_region(sprite.texture,Rect2(available.get_center()-art_size/2,art_size),sprite.region)


func _gui_input(event):
	if event is InputEventMouseMotion:
		var index = at_point(event.position)
		if index != hovered:
			hovered = index
			if index >= 0: menu.preview(entries[index],origin)
			else: menu.preview_selected()
			queue_redraw()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var index = at_point(event.position)
		if index >= 0:
			selected = index
			menu.choose(entries[index],origin)
			queue_redraw()
		accept_event()

func at_point(point: Vector2) -> int:
	for tile in pages[page]:
		if Rect2(Vector2(tile.rect.position)*CELL,Vector2(tile.rect.size)*CELL).has_point(point): return tile.index
	return -1

func deselect_all():
	selected = -1
	queue_redraw()

func turn_page(direction: int):
	page = posmod(page+direction,pages.size())
	hovered = -1
	menu.preview_selected()
	queue_redraw()

func _process(_delta):
	if is_visible_in_tree():
		for tile in pages[page]:
			if tile.item.get("tier",0) >= 2: queue_redraw(); break
