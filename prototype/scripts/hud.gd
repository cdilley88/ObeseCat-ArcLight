extends CanvasLayer

const Loot = preload("res://scripts/loot.gd")
const Skills = preload("res://scripts/skills.gd")
var game
var hub_menu
var root: Control
var life_orb: ColorRect
var mana_orb: ColorRect
var life_value: Label
var mana_value: Label
var xp_bar: ProgressBar
var level_text: Label
var character_button: Button
var character_panel: PanelContainer
var character_summary: Label
var points_text: Label
var derived_text: Label
var attribute_values: Dictionary = {}
var resistance_values: Dictionary = {}
var bonus_text: Label
var affinity_text: Label
var character_tabs: TabContainer
var attribute_buttons: Dictionary = {}
var objective: Label
var circuit: Label
var notice: Label
var inventory_panel: PanelContainer
var inventory_grid
var equipment_slots: Dictionary = {}
var bag_summary: Label
var character_preview
var hover_source: Control
var hover_card: PanelContainer
var hover_delay = 0.0
var drop_button: Button
var detail: Label
var equipped_text: Label
var socket_row: HBoxContainer
var equip_button: Button
var intro: PanelContainer
var title_screen
var bottom_bar: PanelContainer
var weapon_slot_button: Button
var skill_slot_button: Button
var skills_panel: PanelContainer
var skills_points_label: Label
var skills_matrix_label: Label
var skills_resonance_label: Label
var skills_vbox: VBoxContainer
var selection: int = 0
var fx_button: Button
var sound_button: Button
var resolution_button: Button
var msaa_button: Button
var display_button: Button
var scan: ColorRect
var menu_buttons: Dictionary = {}
var potion_buttons: Dictionary = {}
var potion_counts: Dictionary = {}

func _init(owner_game = null):
	game = owner_game

func label(caption: String, size: int = 16, color: Color = Color("c6d5d5")) -> Label:
	var n = Label.new()
	n.text = caption
	n.add_theme_font_size_override("font_size", size)
	n.add_theme_color_override("font_color", color)
	return n

func button(caption: String, callback: Callable) -> Button:
	var b = Button.new()
	b.text = caption
	b.custom_minimum_size.y = 34
	b.pressed.connect(callback)
	b.focus_mode = Control.FOCUS_NONE
	return b

func panel(pos: Vector2, dimensions: Vector2) -> PanelContainer:
	var p = PanelContainer.new()
	p.position = pos
	p.size = dimensions
	var style = StyleBoxFlat.new()
	style.bg_color = Color("101d25f5")
	style.border_color = Color("436365")
	style.set_border_width_all(1)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	p.add_theme_stylebox_override("panel", style)
	root.add_child(p)
	return p

func _ready():
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var theme = Theme.new()
	theme.default_font_size = 15
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color("23343e")
	normal.border_color = Color("527478")
	normal.set_border_width_all(1)
	normal.set_content_margin_all(6)
	theme.set_stylebox("normal", "Button", normal)
	var hover = normal.duplicate()
	hover.bg_color = Color("365763")
	theme.set_stylebox("hover", "Button", hover)
	var pressed = normal.duplicate()
	pressed.bg_color = Color("456657")
	theme.set_stylebox("pressed", "Button", pressed)
	root.theme = theme
	objective = label("", 15, Color("e8c285"))
	objective.position = Vector2(24, 20)
	root.add_child(objective)
	notice = label("", 18, Color("a0ffe0"))
	notice.position = Vector2(32, 632)
	root.add_child(notice)
	life_orb = resource_orb(Vector2(23, 658), Color("c81935"), "LIFE")
	life_value = life_orb.get_node("Value")
	mana_orb = resource_orb(Vector2(1145, 658), Color("2566e8"), "MANA")
	mana_value = mana_orb.get_node("Value")
	for kind in ["life","mana"]:
		var potion = icon_button(kind,"Z" if kind == "life" else "X",kind.capitalize()+" potion",func(): game.drink_potion(kind))
		potion.position = Vector2(148 if kind == "life" else 1062,700)
		root.add_child(potion)
		potion_buttons[kind] = potion
		var count = label("",14)
		count.position = potion.position+Vector2(-4,58)
		count.size.x = 72
		count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		root.add_child(count)
		potion_counts[kind] = count
	weapon_slot_button = button("", func(): game.toggle_inventory())
	weapon_slot_button.custom_minimum_size = Vector2(74, 56)
	weapon_slot_button.position = Vector2(230, 700)
	root.add_child(weapon_slot_button)
	
	var weapon_badge = label("L-CLK", 10, Color("f4da9b"))
	weapon_badge.name = "Badge"
	weapon_badge.position = Vector2(34, 38)
	weapon_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	weapon_slot_button.add_child(weapon_badge)

	var weapon_icon = TextureRect.new()
	weapon_icon.name = "Icon"
	weapon_icon.texture = load("res://assets/ui/character.svg")
	weapon_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	weapon_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	weapon_icon.position = Vector2(8, 4)
	weapon_icon.size = Vector2(38, 38)
	weapon_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	weapon_slot_button.add_child(weapon_icon)

	skill_slot_button = button("", func(): game.toggle_skills())
	skill_slot_button.custom_minimum_size = Vector2(74, 56)
	skill_slot_button.position = Vector2(976, 700)
	root.add_child(skill_slot_button)

	var skill_badge = label("R-CLK", 10, Color("f4da9b"))
	skill_badge.name = "Badge"
	skill_badge.position = Vector2(34, 38)
	skill_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	skill_slot_button.add_child(skill_badge)

	var skill_icon = TextureRect.new()
	skill_icon.name = "Icon"
	skill_icon.texture = load("res://assets/ui/skills.svg") if ResourceLoader.exists("res://assets/ui/skills.svg") else load("res://assets/ui/wormhole.svg")
	skill_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	skill_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	skill_icon.position = Vector2(8, 4)
	skill_icon.size = Vector2(38, 38)
	skill_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	skill_slot_button.add_child(skill_icon)

	bottom_bar = panel(Vector2(314,682),Vector2(652,102))
	var bv = VBoxContainer.new()
	bottom_bar.add_child(bv)
	var br = HBoxContainer.new()
	bv.add_child(br)
	level_text = label("",13,Color("f2cf80"))
	br.add_child(level_text)
	xp_bar = ProgressBar.new()
	xp_bar.custom_minimum_size = Vector2(180,12)
	xp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	xp_bar.show_percentage = false
	var xp_fill = StyleBoxFlat.new()
	xp_fill.bg_color = Color("d6ac57")
	xp_bar.add_theme_stylebox_override("fill",xp_fill)
	var xp_bg = StyleBoxFlat.new()
	xp_bg.bg_color = Color("293841")
	xp_bg.border_color = Color("60747d")
	xp_bg.set_border_width_all(1)
	xp_bar.add_theme_stylebox_override("background",xp_bg)
	br.add_child(xp_bar)
	var menus = HBoxContainer.new()
	menus.add_theme_constant_override("separation",6)
	bv.add_child(menus)
	# Add future menu entries here; icon creation and key badges are shared.
	var entries = [
		["character",game.get_key_name("character"),"Character",func(): game.toggle_character()],
		["inventory",game.get_key_name("inventory"),"Inventory",func(): game.toggle_inventory()],
		["skills",game.get_key_name("skills"),"Skill Matrix & Spells",func(): game.toggle_skills()],
		["map",game.get_key_name("map"),"Tower map",func(): game.open_tower_map()],
		["wormhole",game.get_key_name("wormhole"),"Wormhole: open / return",func(): game.cast_wormhole()],
		["system",game.get_key_name("system"),"Pause / System",func(): game.open_system()]]
	for entry in entries:
		var control = icon_button(entry[0],entry[1],entry[2],entry[3])
		menus.add_child(control)
		menu_buttons[entry[0]] = control
	character_button = menu_buttons.character
	circuit = label("",12,Color("82e4d6"))
	circuit.custom_minimum_size.x = 220
	menus.add_child(circuit)
	build_inventory()
	build_character()
	build_skills()
	build_title_screen()
	hub_menu = preload("res://scripts/hub_menu.gd").new()
	root.add_child(hub_menu)
	hub_menu.setup(game)
	scan = ColorRect.new()
	scan.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scan.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader = ShaderMaterial.new()
	shader.shader = preload("res://shaders/crt.gdshader")
	scan.material = shader
	root.add_child(scan)
	# The overlay stays below readable controls.
	root.move_child(scan, 0)

func update_key_badges():
	if not game: return
	if potion_buttons.has("life"):
		var b = potion_buttons.life.get_node_or_null("Badge")
		if b: b.text = game.get_key_name("potion_life")
	if potion_buttons.has("mana"):
		var b = potion_buttons.mana.get_node_or_null("Badge")
		if b: b.text = game.get_key_name("potion_mana")
	for id in ["character", "inventory", "skills", "map", "wormhole", "system"]:
		if menu_buttons.has(id):
			var b = menu_buttons[id].get_node_or_null("Badge")
			if b: b.text = game.get_key_name(id)

func icon_button(asset: String, key: String, caption: String, action: Callable) -> Button:
	var control = button("",action)
	control.custom_minimum_size = Vector2(56,54)
	control.tooltip_text = caption+" ["+key+"]"
	var icon = TextureRect.new()
	if ResourceLoader.exists("res://assets/ui/"+asset+".svg"):
		icon.texture = load("res://assets/ui/"+asset+".svg")
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.position = Vector2(8,2)
	icon.size = Vector2(40,40)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	control.add_child(icon)
	var badge = label(key,11,Color("f4da9b"))
	badge.name = "Badge"
	badge.position = Vector2(34 if key != "Esc" else 26,37)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	control.add_child(badge)
	return control

func resource_orb(pos: Vector2, color: Color, caption: String) -> ColorRect:
	var orb = ColorRect.new()
	orb.position = pos
	orb.size = Vector2(112, 112)
	orb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material = ShaderMaterial.new()
	material.shader = preload("res://shaders/orb.gdshader")
	material.set_shader_parameter("liquid_color", color)
	orb.material = material
	root.add_child(orb)
	var title = label(caption, 14, Color("f1eee9"))
	title.position = Vector2(0, 30)
	title.size.x = 112
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	orb.add_child(title)
	var value = label("", 15, Color.WHITE)
	value.name = "Value"
	value.position = Vector2(0, 53)
	value.size.x = 112
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value.add_theme_color_override("font_outline_color", Color("101620"))
	value.add_theme_constant_override("outline_size", 4)
	orb.add_child(value)
	return orb

func build_character():
	character_panel = panel(Vector2(32, 104), Vector2(510, 556))
	character_panel.visible = false
	var v = VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	character_tabs = TabContainer.new()
	character_panel.add_child(character_tabs)
	v.name = "Attributes"
	character_tabs.add_child(v)
	var row = HBoxContainer.new()
	v.add_child(row)
	var title = label("CHARACTER / PAUSED", 21, Color("eac982"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title)
	row.add_child(button("CLOSE", func(): game.toggle_character()))
	character_summary = label("", 15)
	v.add_child(character_summary)
	points_text = label("", 18, Color("f4d58a"))
	v.add_child(points_text)
	var descriptions = {"strength": "+0.5 attack damage per point", "dexterity": "+0.2 armor per point", "vitality": "+5 maximum Life per point", "energy": "+5 maximum Mana / +0.1 Mana per second"}
	for attribute in game.Progression.ATTRIBUTES:
		var r = HBoxContainer.new()
		v.add_child(r)
		var texts = VBoxContainer.new()
		texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		r.add_child(texts)
		texts.add_child(label(attribute.capitalize(), 17))
		texts.add_child(label(descriptions[attribute], 12, Color("89a7ac")))
		var value = label("10", 21, Color("e6dcc4"))
		value.custom_minimum_size.x = 36
		r.add_child(value)
		attribute_values[attribute] = value
		var plus = button("+1", func(): game.spend_attribute(attribute))
		plus.custom_minimum_size.x = 45
		r.add_child(plus)
		attribute_buttons[attribute] = plus
	derived_text = label("", 14)
	v.add_child(derived_text)
	v.add_child(label("Five points per level. Session-only character.",12,Color("91a7b3")))
	var defenses = VBoxContainer.new()
	defenses.name = "Elements"
	defenses.add_theme_constant_override("separation",10)
	character_tabs.add_child(defenses)
	defenses.add_child(label("ELEMENTAL DEFENSE",20,Color("eac982")))
	defenses.add_child(label("Resistance / cap 75%",13))
	var element_descriptions = {
		"heat":"Orange / burning damage",
		"cryogenic":"Cyan / slow and brief freeze",
		"electromagnetic":"Yellow / electrical damage",
		"radiation":"Lime / damage over time, local spread",
		"gravity":"Deep purple / capped % maximum Life",
		"corruption":"Magenta / variable damage, stat weakening"}
	for element in Loot.ELEMENTS:
		var element_row = HBoxContainer.new()
		defenses.add_child(element_row)
		var name_label = label(element.capitalize(),18,Loot.TYPES[element])
		name_label.custom_minimum_size.x = 245
		element_row.add_child(name_label)
		var value = label("",18)
		element_row.add_child(value)
		resistance_values[element] = value
		defenses.add_child(label(element_descriptions[element],12,Color("96b1b9")))
	var affinities = VBoxContainer.new()
	affinities.name = "Affinities"
	affinities.add_theme_constant_override("separation",14)
	character_tabs.add_child(affinities)
	affinities.add_child(label("SALVAGE AFFINITIES",20,Color("eac982")))
	affinities.add_child(label("Equipment and creature families / separate from elements",12))
	affinity_text = label("",18)
	affinities.add_child(affinity_text)
	affinities.add_child(label("CYBERNETIC\nWeapons, armor and machine systems.\n\nVISCERAL\nOrganic mutations: teeth, tentacles, living parts.\n\nDRACONIC\nScales, wings and breath weapons.",16))
	affinities.add_child(label("Current gear is Cybernetic. Organic/Draconic content\nmodels remain future content. Family bonuses are active.",13,Color("96b1b9")))

	var mods = ScrollContainer.new()
	mods.name = "Modifiers"
	character_tabs.add_child(mods)
	bonus_text = label("",16)
	mods.add_child(bonus_text)

func refresh_character():
	if not is_instance_valid(character_summary) or game.equipment.is_empty(): return
	var p = game.progression
	var stats: Dictionary = game.current_stats()
	character_summary.text = "LEVEL %d    /    XP %d / %d" % [p.level, p.xp, p.required_xp()]
	points_text.text = "%d UNASSIGNED STAT POINTS" % p.points
	for attribute in p.ATTRIBUTES:
		attribute_values[attribute].text = "%.0f" % (p.attributes[attribute]+stats.get(attribute,0))
		attribute_buttons[attribute].disabled = p.points <= 0
	derived_text.text = "Life %.0f    Mana %.0f    Mana regen %.1f/s\nAttack %.1f    Armor %.1f    Movement %.2f" % [stats.max_life, stats.max_mana, stats.mana_regen, stats.damage, stats.armor, stats.speed]
	derived_text.text += "\nAttack speed +%.0f%% / Reduction %.0f%% / Dodge %.0f%%" % [stats.attack_speed,stats.reduction,stats.dodge]
	if game.player_status.get("weaken",0) > 0: derived_text.text += "\nCORRUPTED: damage/armor -20%"
	for element in resistance_values: resistance_values[element].text = "%.0f%%" % stats[element]
	var counts = {"Cybernetic":0,"Visceral":0,"Draconic":0}
	var seen: Array = []
	for item in game.equipment.values():
		if item.model >= 0 and not Loot.contains_identity(seen,item):
			seen.append(item)
			counts[item.get("affinity","Cybernetic")] += 1
	affinity_text.text = "Worn parts: Cybernetic %d / Visceral %d / Draconic %d" % [counts.Cybernetic,counts.Visceral,counts.Draconic]
	var lines: Array[String] = ["EQUIPMENT MODIFIERS / current totals", "Life regen %.2f/s / Mana regen %.2f/s" % [stats.life_regen,stats.mana_regen]]
	for key in Loot.Bonuses.SPECIAL:
		if key in ["life_regen","mana_regen"]: continue
		if not is_zero_approx(stats.get(key,0)):
			lines.append("%s: %.1f%s" % [Loot.Bonuses.label(key),stats[key],"%" if Loot.Bonuses.percent(key) else ""])
	if stats.get("flat_heat",0) != 0: lines.append("Added Heat damage: +%.0f" % stats.flat_heat)
	bonus_text.text = "\n".join(lines)



func build_skills():
	skills_panel = panel(Vector2(530, 96), Vector2(560, 574))
	skills_panel.visible = false
	var v = VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	skills_panel.add_child(v)
	
	var header = HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	v.add_child(header)
	var title = label("SKILL MATRIX & SPELLBOOK", 18, Color("e5c678"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	
	var close_btn = button("CLOSE [K]", func(): game.toggle_skills())
	header.add_child(close_btn)
	
	skills_matrix_label = label("EQUIPPED MATRIX AFFINITY: CYBERNETIC", 13, Color("76d7ea"))
	v.add_child(skills_matrix_label)
	
	skills_resonance_label = label("AFFINITY RESONANCE: INACTIVE (Need 4+ matching items)", 12, Color("7a8f93"))
	v.add_child(skills_resonance_label)
	
	skills_points_label = label("UNSPENT SKILL POINTS: 0 (+1 per level up)", 14, Color("f4da9b"))
	v.add_child(skills_points_label)
	
	var sep = HSeparator.new()
	v.add_child(sep)
	
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(536, 420)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(scroll)
	
	skills_vbox = VBoxContainer.new()
	skills_vbox.add_theme_constant_override("separation", 8)
	skills_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(skills_vbox)

func refresh_skills():
	if not game or not is_instance_valid(skills_panel): return
	var aff = Skills.get_matrix_affinity(game.equipment)
	var resonance = Skills.has_resonance(game.equipment)
	var count = Skills.count_matching_affinity(game.equipment, aff)
	
	var aff_color = Color("76d7ea") if aff == "Cybernetic" else (Color("9ee62b") if aff == "Visceral" else Color("ff7a2b"))
	skills_matrix_label.text = "EQUIPPED MATRIX AFFINITY: %s" % aff.to_upper()
	skills_matrix_label.add_theme_color_override("font_color", aff_color)
	
	if resonance:
		skills_resonance_label.text = "★ AFFINITY RESONANCE: ACTIVE (+25%% Damage, -20%% Mana Cost, %d/4 pieces)" % count
		skills_resonance_label.add_theme_color_override("font_color", Color("90f5b8"))
	else:
		skills_resonance_label.text = "AFFINITY RESONANCE: INACTIVE (Equip 4+ %s pieces · Currently %d/4)" % [aff, count]
		skills_resonance_label.add_theme_color_override("font_color", Color("829699"))
		
	skills_points_label.text = "UNSPENT SKILL POINTS: %d  (+1 earned every level up)" % game.progression.skill_points
	skills_points_label.add_theme_color_override("font_color", Color("f4da9b") if game.progression.skill_points > 0 else Color("809299"))
	
	for child in skills_vbox.get_children():
		child.queue_free()
		
	for s_id in Skills.LIST:
		var rank = game.skills.get(s_id, 0)
		var s_data = Skills.get_skill_data(s_id, game.equipment, maxi(1, rank))
		var card = PanelContainer.new()
		card.custom_minimum_size = Vector2(520, 94)
		var c_style = StyleBoxFlat.new()
		c_style.bg_color = Color("101d25f5")
		c_style.border_color = Color("436365")
		c_style.set_border_width_all(1)
		c_style.content_margin_left = 16
		c_style.content_margin_right = 16
		c_style.content_margin_top = 10
		c_style.content_margin_bottom = 10
		card.add_theme_stylebox_override("panel", c_style)
		skills_vbox.add_child(card)
		
		var cv = VBoxContainer.new()
		cv.add_theme_constant_override("separation", 3)
		card.add_child(cv)
		
		var top_row = HBoxContainer.new()
		top_row.add_theme_constant_override("separation", 8)
		cv.add_child(top_row)
		
		var name_lbl = label(s_data.name + (" [Rank %d/5]" % rank if rank > 0 else " [Unlearned]"), 14, s_data.color)
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		top_row.add_child(name_lbl)
		
		var is_assigned = (game.assigned_skill == s_id and rank > 0)
		if is_assigned:
			var active_badge = label("★ ACTIVE (R-CLICK)", 12, Color("f4da9b"))
			top_row.add_child(active_badge)
		else:
			var assign_btn = button("ASSIGN TO R-CLICK", func(sid = s_id): game.assign_skill(sid))
			assign_btn.disabled = (rank <= 0)
			assign_btn.custom_minimum_size = Vector2(130, 24)
			top_row.add_child(assign_btn)
			
		var up_btn = button("+ UPGRADE", func(sid = s_id): game.upgrade_skill(sid))
		up_btn.disabled = (game.progression.skill_points <= 0 or rank >= 5 or game.progression.level < s_data.req_level)
		up_btn.custom_minimum_size = Vector2(88, 24)
		top_row.add_child(up_btn)
		
		var sub_text = "%s Element · Mana: %d · Cooldown: %.1fs" % [s_data.element.capitalize(), int(s_data.mana_cost), s_data.cooldown]
		if s_data.base_damage > 0:
			sub_text += " · Base Damage: %d" % int(s_data.base_damage)
		if game.progression.level < s_data.req_level:
			sub_text += " · (Requires Level %d)" % s_data.req_level
		cv.add_child(label(sub_text, 11, Color("b2c5c9")))
		
		cv.add_child(label(s_data.desc, 11, Color("e0e9ea")))
		
		var res_lbl = label("Resonance Perk: " + s_data.resonance_bonus, 11, Color("9ae8b6") if resonance else Color("6e8082"))
		cv.add_child(res_lbl)

func build_inventory():
	inventory_panel = panel(Vector2(475, 91), Vector2(787, 578))
	inventory_panel.visible = false
	var v = VBoxContainer.new()
	v.add_theme_constant_override("separation", 5)
	inventory_panel.add_child(v)
	var title_row = HBoxContainer.new()
	v.add_child(title_row)
	var title = label("FIELD INVENTORY / PAUSED", 20, Color("8be6d4"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title)
	title_row.add_child(button("CLOSE [I]", func(): game.toggle_inventory()))
	var columns = HBoxContainer.new()
	columns.add_theme_constant_override("separation", 16)
	v.add_child(columns)
	var left = VBoxContainer.new()
	left.custom_minimum_size.x = 408
	left.add_theme_constant_override("separation", 4)
	columns.add_child(left)
	var slots = GridContainer.new()
	slots.columns = 4
	slots.add_theme_constant_override("h_separation", 8)
	slots.add_theme_constant_override("v_separation", 3)
	left.add_child(slots)
	for slot in Loot.SLOTS:
		var control = preload("res://scripts/equipment_slot.gd").new()
		slots.add_child(control)
		control.setup(self, slot)
		equipment_slots[slot] = control
	bag_summary = label("", 13, Color("e9bd80"))
	left.add_child(bag_summary)
	inventory_grid = preload("res://scripts/inventory_grid.gd").new()
	left.add_child(inventory_grid)
	inventory_grid.setup(self)
	var actions = HBoxContainer.new()
	left.add_child(actions)
	actions.add_child(button("AUTO-PACK", func(): game.auto_pack()))
	drop_button = button("DROP SELECTED", func(): game.drop_inventory_item(selection))
	actions.add_child(drop_button)
	left.add_child(label("Drag to move / equip. Right-click or double-click to equip.\nDrag worn gear into the backpack to unequip. No rotation.", 12, Color("8eafb5")))
	var right = VBoxContainer.new()
	right.custom_minimum_size.x = 313
	right.add_theme_constant_override("separation", 6)
	columns.add_child(right)
	var preview_header = HBoxContainer.new()
	right.add_child(preview_header)
	equipped_text = label("FITTING BAY",15,Color("8be6d4"))
	equipped_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_header.add_child(equipped_text)
	preview_header.add_child(button("<",func(): character_preview.turn(-PI/6)))
	preview_header.add_child(button(">",func(): character_preview.turn(PI/6)))
	character_preview = preload("res://scripts/character_preview.gd").new()
	right.add_child(character_preview)
	character_preview.setup(game)
	right.add_child(label("Hover a part to inspect it. C opens full stats.",12,Color("8eafb5")))
	detail = label("",14)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.custom_minimum_size = Vector2(313,38)
	right.add_child(detail)
	equip_button = button("EQUIP SELECTED", func(): activate_item(selection))
	right.add_child(equip_button)
	right.add_child(label("MATRIX SOCKETS · click to cycle", 13, Color("e9bd80")))
	socket_row = HBoxContainer.new()
	right.add_child(socket_row)
	var help = label("Capacitor > Relay > Ground\nStand still 1.5s; next hit pulses. Cooldown: 5s.\nReplaces parts: +2 damage / +0.15 speed / +1 armor.", 12, Color("94b6bc"))
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(help)

func build_title_screen():
	title_screen = preload("res://scripts/title_screen.gd").new()
	title_screen.setup(game, self)
	root.add_child(title_screen)
	intro = title_screen.main_card

func show_title():
	if is_instance_valid(title_screen):
		title_screen.show_menu()
	update_hud()

func select_item(index: int):
	selection = index
	refresh_details()
	for child in inventory_grid.get_children(): child.queue_redraw()
	for slot in equipment_slots.values():
		for child in slot.get_children(): child.queue_redraw()

func activate_item(index: int):
	if index < 0 or index >= game.inventory.size(): return
	selection = index
	if game.Backpack.worn(game.inventory[index], game.equipment): game.unequip_item(index)
	else: game.equip_item(index)
	refresh_inventory()

func refresh_inventory():
	hide_item_card()
	refresh_preview()
	if not is_instance_valid(equipped_text): return
	selection = clampi(selection, -1 if game.inventory.is_empty() else 0, game.inventory.size() - 1)
	var used: int = game.Backpack.used_cells(game.inventory, game.equipment)
	bag_summary.text = "BACKPACK 12 x 8   /   %d of 96 cells occupied" % used
	inventory_grid.refresh()
	for slot in equipment_slots.values(): slot.refresh()
	refresh_details()
	for child in socket_row.get_children():
		socket_row.remove_child(child)
		child.queue_free()
	if game.equipment.matrix.sockets.is_empty():
		socket_row.add_child(label("Equip a Circuit matrix for sockets.", 12))
	else:
		for i in range(3):
			var b = button("%d: %s" % [i + 1, game.equipment.matrix.sockets[i]], func(): game.cycle_socket(i); refresh_inventory())
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			b.add_theme_font_size_override("font_size", 11)
			socket_row.add_child(b)

func refresh_details():
	var valid = selection >= 0 and selection < game.inventory.size()
	equip_button.disabled = not valid
	drop_button.disabled = not valid
	if not valid:
		detail.text = "Select a part to equip or drop."
		return
	var item: Dictionary = game.inventory[selection]
	var worn: bool = game.Backpack.worn(item,game.equipment)
	detail.text = item.name + (" / WORN" if worn else "")
	detail.add_theme_color_override("font_color",Loot.color(item))
	equip_button.text = "UNEQUIP TO BACKPACK" if worn else "EQUIP SELECTED"

func refresh_preview():
	if is_instance_valid(character_preview): character_preview.refresh()

func hover_item(source: Control):
	hide_item_card()
	hover_source = source
	hover_delay = 0.18

func leave_item(source: Control):
	if hover_source == source: hide_item_card()

func hide_item_card():
	hover_source = null
	if is_instance_valid(hover_card):
		hover_card.hide()
		hover_card.queue_free()
		hover_card = null

func _process(delta):
	if not is_instance_valid(hover_source):
		if is_instance_valid(hover_card): hide_item_card()
		return
	if not game.inventory_open or not hover_source.is_visible_in_tree() or get_viewport().gui_is_dragging() or not hover_source.get_global_rect().has_point(root.get_global_mouse_position()):
		hide_item_card()
		return
	hover_delay -= delta
	if hover_delay > 0: return
	if not is_instance_valid(hover_card):
		var index: int = hover_source.index
		if index < 0 or index >= game.inventory.size():
			hide_item_card()
			return
		hover_card = preload("res://scripts/item_card.gd").new()
		hover_card.setup(game.inventory[index],game.Backpack.worn(game.inventory[index],game.equipment))
		root.add_child(hover_card)
	hover_card.size = hover_card.get_combined_minimum_size()
	var bounds = root.get_viewport_rect().size
	var desired_x = inventory_panel.position.x-hover_card.size.x-12
	if desired_x < 8: desired_x = root.get_global_mouse_position().x+20
	hover_card.position = Vector2(clampf(desired_x,8,maxf(8,bounds.x-hover_card.size.x-8)),clampf(root.get_global_mouse_position().y-45,8,maxf(8,bounds.y-hover_card.size.y-8)))

func update_hud():
	var stats: Dictionary = game.current_stats()
	life_orb.material.set_shader_parameter("fill", game.hp / stats.max_life)
	mana_orb.material.set_shader_parameter("fill", game.mana / stats.max_mana)
	life_value.text = "%d / %d" % [ceili(game.hp), int(stats.max_life)]
	mana_value.text = "%d / %d" % [floori(game.mana), int(stats.max_mana)]
	level_text.text = "LV %d  ·  XP %d/%d" % [game.progression.level, game.progression.xp, game.progression.required_xp()]
	xp_bar.max_value = game.progression.required_xp()
	xp_bar.value = game.progression.xp
	character_button.self_modulate = Color("ffd487") if game.progression.points > 0 else Color.WHITE
	character_button.tooltip_text = "Character [C] / %d unspent points" % game.progression.points
	for kind in potion_counts:
		potion_counts[kind].text = "%d / 99" % game.potions[kind]
		potion_buttons[kind].self_modulate = Color("667780") if game.potions[kind] == 0 or game.potion_cooldowns[kind] > 0 else Color.WHITE
	circuit.text = ""
	if stats.circuit:
		circuit.text = "CIRCUIT " + ("READY" if game.charge >= 1.5 else ("COOLING" if game.circuit_cooldown > 0 else "CHARGING"))
	if game.player_status.stop > 0: circuit.text += "\nSIGNAL STALL"
	elif game.player_status.slow > 0: circuit.text += "\nSIGNAL SLOW"
	if game.player_status.burn > 0: circuit.text += "\n"+game.player_status.get("dot_type","radiation").to_upper()+" BURN"
	if game.player_status.get("weaken",0) > 0: circuit.text += "\nCORRUPTED"
	if game.empowered: circuit.text += "\nEMPOWERED"
	objective.text = "GARAGE REFUGE  /  %d Si" % game.silicon
	if game.Tower.ZONES.has(game.area):
		objective.text = "%s  /  %d Si" % [game.Tower.ZONES[game.area].name,game.silicon]
		if game.keycards.has(game.area): objective.text += "  /  KEYCARD"
	if game.area == "debug_arena": objective.text = "DEBUG RANGE / %d Si" % game.silicon
	if game.hp <= 0: objective.text += "\nDEFEATED / T: recover"
	elif game.act_complete: objective.text += "  /  ACT I COMPLETE"

	var in_game = game.started
	life_orb.visible = in_game
	mana_orb.visible = in_game
	if is_instance_valid(bottom_bar): bottom_bar.visible = in_game
	objective.visible = in_game
	notice.visible = in_game and game.message_time > 0
	notice.text = game.message if game.message_time > 0 else ""
	for kind in potion_buttons:
		potion_buttons[kind].visible = in_game
		potion_counts[kind].visible = in_game
	if is_instance_valid(title_screen):
		title_screen.visible = not in_game
		if not in_game:
			title_screen.refresh_save_status()
	intro.visible = not in_game
	hub_menu.visible = in_game and game.menu_open != ""
	inventory_panel.visible = in_game and game.inventory_open
	character_panel.visible = in_game and game.character_open
	if is_instance_valid(skills_panel):
		skills_panel.visible = in_game and game.skills_open
		if in_game and game.skills_open: refresh_skills()
	if in_game and game.character_open: refresh_character()
	
	if is_instance_valid(weapon_slot_button):
		weapon_slot_button.visible = in_game
		if in_game:
			var w = game.selected_weapon()
			var w_color = Loot.TYPES.get(w.get("type", "physical"), Color("829699"))
			weapon_slot_button.tooltip_text = "WEAPON: %s\nDamage: %d  Reach: %.1fm  Type: %s\n[Click / I: Inventory]" % [
				w.name, int(w.damage), float(w.reach), str(w.type).capitalize()
			]
			var sb = StyleBoxFlat.new()
			sb.bg_color = Color("151f28")
			sb.border_color = w_color
			sb.set_border_width_all(2)
			weapon_slot_button.add_theme_stylebox_override("normal", sb)

	if is_instance_valid(skill_slot_button):
		skill_slot_button.visible = in_game
		if in_game:
			var s_rank = game.skills.get(game.assigned_skill, 0)
			var s_data = Skills.get_skill_data(game.assigned_skill, game.equipment, maxi(1, s_rank))
			var cd = game.skill_cooldowns.get(game.assigned_skill, 0.0)
			var s_color = s_data.get("color", Color("829699"))
			if cd > 0:
				skill_slot_button.tooltip_text = "SKILL: %s (Cooldown: %.1fs)\n[Click / K: Skills]" % [s_data.name, cd]
			else:
				skill_slot_button.tooltip_text = "SKILL: %s [Rank %d/5]\nMana Cost: %d  Element: %s\n[Click / K: Skills]" % [
					s_data.name, s_rank, int(s_data.get("mana_cost", 0)), str(s_data.get("element", "")).capitalize()
				]
			var s_sb = StyleBoxFlat.new()
			s_sb.bg_color = Color("1a1824") if cd <= 0 else Color("0d0d12")
			s_sb.border_color = s_color if cd <= 0 else Color("40484e")
			s_sb.set_border_width_all(2)
			skill_slot_button.add_theme_stylebox_override("normal", s_sb)
			
	if is_instance_valid(fx_button): fx_button.text = "CRT SCANLINES: ON [F]" if game.effects_enabled else "CRT SCANLINES: OFF [F]"
	if is_instance_valid(sound_button): sound_button.text = "AUDIO SFX: ON [M]" if game.sound_enabled else "AUDIO SFX: OFF [M]"
	if is_instance_valid(resolution_button): resolution_button.text = "SCALE: CRISP 1280x800" if game.crisp_graphics else "SCALE: RETRO 640x400"
	if is_instance_valid(msaa_button): msaa_button.text = "MSAA 3D: " + game.msaa_name()
	if is_instance_valid(display_button): display_button.text = "DISPLAY: FULLSCREEN [F11]" if game.is_fullscreen() else "DISPLAY: WINDOWED [F11]"
	scan.material.set_shader_parameter("enabled", game.effects_enabled)

