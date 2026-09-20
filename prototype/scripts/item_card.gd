extends PanelContainer
## Read-only item presentation. Totals include rolled values and active loose parts.
const Loot = preload("res://scripts/loot.gd")
var shown_item: Dictionary = {}
const NAMES = {"heat":"Heat resistance","cryogenic":"Cryogenic resistance","electromagnetic":"Electromagnetic resistance","damage":"Damage", "strength":"Strength", "dexterity":"Dexterity", "vitality":"Vitality", "energy":"Energy", "life":"Life", "mana":"Mana", "speed":"Movement speed", "attack_speed":"Attack speed", "reduction":"Damage reduction", "radiation":"Radiation resistance", "gravity":"Gravity resistance", "corruption":"Corruption resistance", "dodge":"Gravity dodge"}
const PERCENT = ["attack_speed","reduction","heat","cryogenic","electromagnetic","radiation","gravity","corruption","dodge"]

static func number(value: float) -> String:
	return str(int(value)) if is_equal_approx(value,roundf(value)) else ("%.2f" % value).trim_suffix("0").trim_suffix("0").trim_suffix(".")

static func content(item: Dictionary) -> Dictionary:
	var damage = float(item.damage)
	var armor = float(item.armor)
	var move_bonus = float(item.speed)
	var active = Loot.circuit_active(item)
	if not active:
		for part in item.sockets:
			if part == "Capacitor": damage += 2
			if part == "Ground": armor += 1
			if part == "Relay": move_bonus += 0.15
	var totals: Array[String] = []
	if item.slot == "weapon": totals.append("%s %s damage" % [number(damage),item.type.capitalize()])
	elif not is_zero_approx(damage): totals.append("+%s Damage" % number(damage))
	if not is_zero_approx(armor): totals.append("%s Defense" % number(armor))
	var bonuses: Array[String] = []
	if item.get("unique_id","") == "chefbot_hat": bonuses.append("+3 All Stats")
	if item.get("flat_heat",0) != 0: bonuses.append("+%s Heat damage" % number(item.flat_heat))
	for key in NAMES:
		if item.get("unique_id","") == "chefbot_hat" and key in ["strength","dexterity","vitality","energy"]: continue
		var value = float(item.get(key,0))
		if key == "damage":
			# Show the random contribution beneath the already-inclusive total.
			value = 0
			for mod in item.get("affixes",[]):
				if mod.key == "damage": value += mod.value
		if key == "speed": value = move_bonus
		if is_zero_approx(value): continue
		bonuses.append("%s%s%s %s" % ["+" if value > 0 else "",number(value),"%" if key in PERCENT else "",NAMES[key]])
	for key in Loot.Bonuses.ALL:
		if key in NAMES or is_zero_approx(float(item.get(key,0))): continue
		bonuses.append("+%s%s %s" % [number(item[key]),"%" if Loot.Bonuses.percent(key) else "",Loot.Bonuses.label(key)])
	var effects: Array[String] = []
	if item.slot == "weapon":
		match item.type:
			"heat": effects.append("Burns for 3 seconds.")
			"cryogenic": effects.append("Slows; every third hit briefly freezes.")
			"electromagnetic": effects.append("80-120% electrical damage.")
			"radiation": effects.append("Irradiates for 3s; spreads once to neighbors.")
			"gravity": effects.append("Flat hit + 3% maximum Life (capped).")
			"corruption": effects.append("50-150% damage; weakens damage/armor.")
		if item.get("splash",0) > 0: effects.append("Missile explodes for full damage in its radius." if item.get("attack","") == "missile" else "Explodes for 50% splash damage.")
	if item.get("signature",false): effects.append("Hits one extra target for 70% damage.")
	if active: effects.append("Emergency Return: charge while still;\non hit, release a defensive pulse.")
	var category: String = item.slot.capitalize()
	if item.slot == "weapon": category = "Two-slot weapon" if item.hands == 2 else "One-slot weapon"
	return {"totals":"  /  ".join(totals),"bonuses":"\n".join(bonuses),"effects":"\n".join(effects),"category":category}

func text_line(box: VBoxContainer, value: String, font_size: int, color: Color):
	if value == "": return
	var text = Label.new()
	text.text = value
	text.custom_minimum_size.x = 272
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.add_theme_font_size_override("font_size",font_size)
	text.add_theme_color_override("font_color",color)
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(text)

func setup(item: Dictionary, worn: bool, action_hint: String = ""):
	shown_item = item
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size.x = 300
	var style = StyleBoxFlat.new()
	style.bg_color = Color("080f16fa")
	style.border_color = Loot.color(item).darkened(0.2)
	style.set_border_width_all(2)
	style.set_content_margin_all(14)
	style.shadow_color = Color(0,0,0,0.5)
	style.shadow_size = 8
	add_theme_stylebox_override("panel",style)
	var box = VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation",7)
	add_child(box)
	var art = TextureRect.new()
	art.texture = load(item.icon)
	art.custom_minimum_size = Vector2(272,76)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(art)
	var data = content(item)
	text_line(box,item.name,19,Loot.color(item))
	text_line(box,item.affix + " / " + item.get("affinity","Cybernetic") + " / " + data.category + (" / Worn" if worn else ""),12,Color("92aab5"))
	text_line(box,data.totals,18,Color("f1e6cd"))
	if item.slot == "weapon": text_line(box,"%.2fs attack interval" % item.period,12,Color("92aab5"))
	if data.bonuses != "":
		var separator = HSeparator.new()
		separator.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(separator)
		text_line(box,data.bonuses,15,Color("9fbaff"))
	text_line(box,data.effects,13,Color("91dac9"))
	if not item.sockets.is_empty(): text_line(box,"Sockets: " + " / ".join(item.sockets),12,Color("d5b981"))
	text_line(box,"%d x %d cells / %s" % [item.width,item.height,action_hint if action_hint != "" else "Right-click to " + ("unequip" if worn else "equip")],11,Color("718d99"))

func _process(_delta):
	if is_visible_in_tree() and shown_item.get("tier",0) >= 2: queue_redraw()
func _draw():
	var animate = true
	var ancestor = get_parent()
	while ancestor != null:
		var owner_game = ancestor.get("game")
		if owner_game != null:
			animate = owner_game.effects_enabled
			break
		ancestor = ancestor.get_parent()
	preload("res://scripts/rarity_fx.gd").paint(self,Rect2(Vector2.ONE,size-Vector2.ONE*2),shown_item,animate)
