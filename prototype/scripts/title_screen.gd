extends Control

var game
var hud
var splash_layer: Control
var video_player: VideoStreamPlayer
var skip_hint: Label
var menu_layer: Control
var main_card: PanelContainer
var continue_button: Button
var continue_badge: Label
var new_game_button: Button
var options_button: Button
var credits_button: Button
var quit_button: Button

var modal_backdrop: ColorRect
var options_modal: PanelContainer
var credits_modal: PanelContainer
var confirm_modal: PanelContainer
var delete_confirm_modal: PanelContainer
var keybinds_modal: PanelContainer
var keybinds_status_lbl: Label
var keybinds_grid: GridContainer
var keybinds_rebinding_action: String = ""

var crt_button: Button
var sound_button: Button
var resolution_button: Button
var msaa_button: Button
var display_button: Button
var seed_field: SpinBox
var save_info_label: Label
var delete_save_button: Button
var confirm_msg: Label

var state: String = "splash" # "splash", "menu", "options", "credits", "confirm", "delete_confirm", "keybinds"
var video_loaded: bool = false

const SaveManager = preload("res://scripts/save_manager.gd")

func setup(owner_game, owner_hud):
	game = owner_game
	hud = owner_hud

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_PASS
	build_splash_layer()
	build_menu_layer()
	build_modals()
	
	# In headless mode (automated tests/CI), immediately skip splash to avoid waiting.
	if DisplayServer.get_name() == "headless":
		skip_splash()
	else:
		start_splash()

func _unhandled_input(event):
	if not visible:
		return
	if state == "splash":
		if (event is InputEventKey and event.pressed) or (event is InputEventMouseButton and event.pressed):
			skip_splash()
			get_viewport().set_input_as_handled()
	elif state == "menu":
		if event is InputEventKey and event.pressed:
			if event.keycode == KEY_F:
				if game: game.toggle_fx()
				refresh_options()
				get_viewport().set_input_as_handled()
			elif event.keycode == KEY_M:
				if game: game.toggle_sound()
				refresh_options()
				get_viewport().set_input_as_handled()
			elif event.keycode == KEY_F11:
				if game: game.toggle_fullscreen()
				refresh_options()
				get_viewport().set_input_as_handled()
			elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
				if continue_button and not continue_button.disabled:
					on_continue_pressed()
				else:
					on_new_game_pressed()
				get_viewport().set_input_as_handled()
	elif state in ["options", "credits", "confirm", "delete_confirm"]:
		if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
			close_modals()
			get_viewport().set_input_as_handled()
	elif state == "keybinds":
		if keybinds_rebinding_action != "":
			if event is InputEventKey and event.pressed and not event.echo:
				if event.keycode == KEY_ESCAPE:
					keybinds_rebinding_action = ""
					refresh_keybinds_modal()
				else:
					if game:
						game.rebind_key(keybinds_rebinding_action, event.physical_keycode)
					keybinds_rebinding_action = ""
					refresh_keybinds_modal()
				get_viewport().set_input_as_handled()
		else:
			if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
				keybinds_rebinding_action = ""
				keybinds_modal.visible = false
				state = "options"
				options_modal.visible = true
				get_viewport().set_input_as_handled()

func styled_button(caption: String, callback: Callable) -> Button:
	var b = Button.new()
	b.text = caption
	b.custom_minimum_size.y = 38
	b.pressed.connect(callback)
	b.focus_mode = Control.FOCUS_NONE
	var style = StyleBoxFlat.new()
	style.bg_color = Color("1e303b")
	style.border_color = Color("456b73")
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(8)
	b.add_theme_stylebox_override("normal", style)
	var hover = style.duplicate()
	hover.bg_color = Color("2e4a57")
	hover.border_color = Color("68a0ab")
	b.add_theme_stylebox_override("hover", hover)
	var pressed = style.duplicate()
	pressed.bg_color = Color("385f58")
	pressed.border_color = Color("76cdb8")
	b.add_theme_stylebox_override("pressed", pressed)
	var disabled = style.duplicate()
	disabled.bg_color = Color("141e24")
	disabled.border_color = Color("28373d")
	b.add_theme_stylebox_override("disabled", disabled)
	return b

func styled_label(text_content: String, font_size: int = 14, color: Color = Color("c6d5d5")) -> Label:
	var l = Label.new()
	l.text = text_content
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	return l

func build_splash_layer():
	splash_layer = Control.new()
	splash_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	splash_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(splash_layer)
	
	# Solid black backdrop for video playback
	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color.BLACK
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	splash_layer.add_child(bg)
	
	video_player = VideoStreamPlayer.new()
	video_player.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	video_player.expand = true
	video_player.mouse_filter = Control.MOUSE_FILTER_IGNORE
	video_player.finished.connect(_on_video_finished)
	splash_layer.add_child(video_player)
	
	skip_hint = styled_label("[ PRESS ANY KEY OR CLICK TO SKIP ]", 12, Color(0.75, 0.85, 0.88, 0.55))
	skip_hint.position = Vector2(960, 755)
	skip_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	splash_layer.add_child(skip_hint)
	
	# Intercept mouse click directly on splash layer
	splash_layer.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed:
			skip_splash()
	)

func start_splash():
	state = "splash"
	splash_layer.visible = true
	menu_layer.visible = false
	if ResourceLoader.exists("res://assets/video/its_presents_arclight.ogv"):
		var stream = load("res://assets/video/its_presents_arclight.ogv")
		if stream:
			video_player.stream = stream
			video_loaded = true
			video_player.play()
			return
	# Fallback if video file missing
	skip_splash()

func _on_video_finished():
	skip_splash()

func skip_splash():
	if state != "splash" and not splash_layer.visible:
		return
	if is_instance_valid(video_player):
		video_player.stop()
	splash_layer.visible = false
	show_menu()

func build_menu_layer():
	menu_layer = Control.new()
	menu_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(menu_layer)
	
	main_card = PanelContainer.new()
	main_card.position = Vector2(370, 50)
	main_card.size = Vector2(540, 700)
	var style = StyleBoxFlat.new()
	style.bg_color = Color("0d1820ee") # Translucent dark slate showing 3D garage behind
	style.border_color = Color("385863")
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 28
	style.content_margin_right = 28
	style.content_margin_top = 22
	style.content_margin_bottom = 20
	main_card.add_theme_stylebox_override("panel", style)
	menu_layer.add_child(main_card)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	main_card.add_child(vbox)
	
	# Subtitle / Presenter tag
	var pres = styled_label("INTEGRALTEC SYSTEMS PRESENTS", 11, Color("7de8d2"))
	pres.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(pres)
	
	# Original Logo Asset
	var logo_rect = TextureRect.new()
	if ResourceLoader.exists("res://assets/ui/arclight_logo.png"):
		logo_rect.texture = load("res://assets/ui/arclight_logo.png")
	logo_rect.custom_minimum_size = Vector2(480, 145)
	logo_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	vbox.add_child(logo_rect)
	
	# Version & Protocol Banner
	var sub = styled_label("OBESECAT ARCLIGHT  ·  TECH DEMO 0.15", 13, Color("ffd16b"))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(sub)
	
	var desc = styled_label("Automated Tower Monolith  /  18 Floor Infiltration\nSalvage Cybernetic circuitry · Slay Supervisors · Breach Penthouse 19", 12, Color("8ba8af"))
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(desc)
	
	# Divider
	var div = HSeparator.new()
	var div_style = StyleBoxLine.new()
	div_style.color = Color("2e464f")
	div_style.thickness = 1
	div.add_theme_stylebox_override("separator", div_style)
	vbox.add_child(div)
	
	# Action buttons column
	var btns = VBoxContainer.new()
	btns.add_theme_constant_override("separation", 8)
	vbox.add_child(btns)
	
	continue_button = styled_button("CONTINUE GAME", on_continue_pressed)
	btns.add_child(continue_button)
	
	continue_badge = styled_label("", 11, Color("ffe28a"))
	continue_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	btns.add_child(continue_badge)
	
	new_game_button = styled_button("NEW GAME", on_new_game_pressed)
	btns.add_child(new_game_button)
	
	options_button = styled_button("OPTIONS", on_options_pressed)
	btns.add_child(options_button)
	
	credits_button = styled_button("CREDITS & INTEL", on_credits_pressed)
	btns.add_child(credits_button)
	
	quit_button = styled_button("QUIT TO DESKTOP", on_quit_pressed)
	# Disable quit button on web target where quitting is not applicable
	if OS.has_feature("web"):
		quit_button.visible = false
	btns.add_child(quit_button)
	
	# Footer
	var foot = styled_label("Space / Enter: Confirm   ·   [F] CRT Shader   ·   [M] Sound", 11, Color("5c767e"))
	foot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(foot)

func build_modals():
	# Fullscreen dark dimming backdrop for modals to prevent bleed-through
	modal_backdrop = ColorRect.new()
	modal_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal_backdrop.color = Color(0.02, 0.04, 0.07, 0.82)
	modal_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	modal_backdrop.visible = false
	modal_backdrop.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed:
			close_modals()
	)
	add_child(modal_backdrop)
	
	# Base solid modal styling (fully opaque to prevent background bleed-through)
	var modal_box = StyleBoxFlat.new()
	modal_box.bg_color = Color("0c171e")
	modal_box.border_color = Color("4b727d")
	modal_box.set_border_width_all(1)
	modal_box.set_corner_radius_all(6)
	modal_box.content_margin_left = 24
	modal_box.content_margin_right = 24
	modal_box.content_margin_top = 20
	modal_box.content_margin_bottom = 20
	
	# ---------------- Options Modal ----------------
	options_modal = PanelContainer.new()
	options_modal.position = Vector2(370, 45)
	options_modal.size = Vector2(540, 680)
	options_modal.add_theme_stylebox_override("panel", modal_box)
	options_modal.visible = false
	add_child(options_modal)
	
	var opt_vbox = VBoxContainer.new()
	opt_vbox.add_theme_constant_override("separation", 10)
	options_modal.add_child(opt_vbox)
	
	opt_vbox.add_child(styled_label("OPTIONS", 18, Color("7fead4")))
	opt_vbox.add_child(styled_label("Display, Graphics, Audio & Save File Management", 12, Color("8ba8af")))
	
	resolution_button = styled_button("GRAPHICS SCALE: CRISP 1280x800", func():
		if game: game.toggle_resolution()
		refresh_options()
	)
	opt_vbox.add_child(resolution_button)
	
	msaa_button = styled_button("ANTI-ALIASING (MSAA 3D): 4X", func():
		if game: game.cycle_msaa()
		refresh_options()
	)
	opt_vbox.add_child(msaa_button)
	
	display_button = styled_button("DISPLAY MODE: WINDOWED [F11]", func():
		if game: game.toggle_fullscreen()
		refresh_options()
	)
	opt_vbox.add_child(display_button)
	
	crt_button = styled_button("CRT SCANLINES: ON [F]", func():
		if game: game.toggle_fx()
		refresh_options()
	)
	opt_vbox.add_child(crt_button)
	
	sound_button = styled_button("AUDIO SFX: ON [M]", func():
		if game: game.toggle_sound()
		refresh_options()
	)
	opt_vbox.add_child(sound_button)
	
	var keybinds_btn = styled_button("CUSTOMIZE KEYBOARD CONTROLS...", on_keybinds_pressed)
	opt_vbox.add_child(keybinds_btn)
	
	var seed_row = HBoxContainer.new()
	seed_row.add_theme_constant_override("separation", 10)
	opt_vbox.add_child(seed_row)
	seed_row.add_child(styled_label("WORLD SEED:", 13, Color("ffd16b")))
	seed_field = SpinBox.new()
	seed_field.min_value = 1
	seed_field.max_value = 2147483646
	seed_field.step = 1
	seed_field.value = game.run_seed if game else 42
	seed_field.custom_minimum_size.x = 160
	seed_field.value_changed.connect(func(v):
		if game: game.apply_world_seed(int(v))
	)
	seed_row.add_child(seed_field)
	
	var seed_rand = styled_button("REROLL", func():
		if game:
			var fresh_seed = game.WorldRandom.fresh(game.run_seed)
			seed_field.value = fresh_seed
			game.apply_world_seed(fresh_seed)
	)
	seed_row.add_child(seed_rand)
	
	# Save file management inside options
	var save_div = HSeparator.new()
	var s_style = StyleBoxLine.new()
	s_style.color = Color("2e464f")
	save_div.add_theme_stylebox_override("separator", s_style)
	opt_vbox.add_child(save_div)
	
	opt_vbox.add_child(styled_label("SAVE FILE STATUS", 14, Color("ffd16b")))
	save_info_label = styled_label("Checking save status...", 12, Color("a8c0c6"))
	opt_vbox.add_child(save_info_label)
	
	delete_save_button = styled_button("DELETE SAVE FILE...", func():
		if game and game.sound_enabled: game.tone("equip")
		state = "delete_confirm"
		options_modal.visible = false
		delete_confirm_modal.visible = true
	)
	opt_vbox.add_child(delete_save_button)
	
	var replay_btn = styled_button("REPLAY DEVELOPER INTRO FMV", func():
		close_modals()
		start_splash()
	)
	opt_vbox.add_child(replay_btn)
	
	var opt_close = styled_button("RETURN TO MAIN MENU [ESC]", close_modals)
	opt_vbox.add_child(opt_close)
	
	# ---------------- Credits Modal (Fixed Layout!) ----------------
	credits_modal = PanelContainer.new()
	credits_modal.position = Vector2(360, 90)
	credits_modal.size = Vector2(560, 580)
	credits_modal.add_theme_stylebox_override("panel", modal_box.duplicate())
	credits_modal.visible = false
	add_child(credits_modal)
	
	var cred_vbox = VBoxContainer.new()
	cred_vbox.add_theme_constant_override("separation", 10)
	credits_modal.add_child(cred_vbox)
	
	cred_vbox.add_child(styled_label("MISSION INTEL & CREDITS", 17, Color("7fead4")))
	
	var scroll = ScrollContainer.new()
	scroll.name = "ScrollContainer"
	scroll.custom_minimum_size = Vector2(500, 440)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	cred_vbox.add_child(scroll)
	
	# Explicit width on intel_text ensures AUTOWRAP wraps at full width instead of 1 character!
	var intel_text = styled_label(
		"DEVELOPER & PRODUCTION\n" +
		"IntegralTec Systems  ·  CDilley\n\n" +
		"ORIGINAL ASSETS\n" +
		"• Developer Splash FMV: Adobe Premiere Pro CS6 Master\n" +
		"• ArcLight Hero Insignia: Original RGBA Insignia\n" +
		"• Engine Video Codec: Transcoded for Godot 4 via Theora / Vorbis\n\n" +
		"UNIVERSE & SETTING\n" +
		"ObeseCat Universe  ·  Autonomous Systems Outpost\n" +
		"The descent is into glitched corruption within an alternate Cold War corporate tower.\n" +
		"Pacing inspired by Diablo 1; equipment depth informed by Diablo 2.\n" +
		"Tone balances 1990s Westwood Red Alert seriousness with underlying absurdity.\n\n" +
		"MISSION OBJECTIVE\n" +
		"Ascend 18 randomized floors across six security zones.\n" +
		"Defeat Area Supervisors to acquire keycards.\n" +
		"Salvage Cybernetic, Draconic, and Visceral equipment.\n" +
		"Ascend to Penthouse 19 to confront the Machine Intelligence: ObeseCat.\n\n" +
		"ENGINE & SPECS\n" +
		"Godot Engine 4.3 (GL Compatibility)\n" +
		"Viewport: 16:10 Aspect (1280x800 Viewport / 640x400 Internal)\n" +
		"Audio: Dynamic synthesized 16-bit waveforms\n" +
		"Saves: Persistent JSON Serialization (user://arclight_save.json)",
		13,
		Color("b6c8cd")
	)
	intel_text.custom_minimum_size = Vector2(490, 0)
	intel_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	intel_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	scroll.add_child(intel_text)
	
	var cred_close = styled_button("RETURN TO MAIN MENU [ESC]", close_modals)
	cred_vbox.add_child(cred_close)
	
	# ---------------- Confirm Overwrite Modal ----------------
	confirm_modal = PanelContainer.new()
	confirm_modal.position = Vector2(400, 230)
	confirm_modal.size = Vector2(480, 270)
	confirm_modal.add_theme_stylebox_override("panel", modal_box.duplicate())
	confirm_modal.visible = false
	add_child(confirm_modal)
	
	var conf_vbox = VBoxContainer.new()
	conf_vbox.add_theme_constant_override("separation", 14)
	confirm_modal.add_child(conf_vbox)
	
	conf_vbox.add_child(styled_label("START NEW GAME?", 17, Color("ff9671")))
	confirm_msg = styled_label(
		"An active game save exists on disk.\n" +
		"Starting a new game will overwrite your saved character,\n" +
		"collected Silicon, and Tower floor progress.\n\n" +
		"Start a new game?",
		13,
		Color("dce7ea")
	)
	conf_vbox.add_child(confirm_msg)
	
	var conf_row = HBoxContainer.new()
	conf_row.add_theme_constant_override("separation", 10)
	conf_vbox.add_child(conf_row)
	
	var confirm_yes = styled_button("OVERWRITE & START", func():
		close_modals()
		start_fresh_game()
	)
	confirm_yes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	conf_row.add_child(confirm_yes)
	
	var confirm_no = styled_button("CANCEL", close_modals)
	confirm_no.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	conf_row.add_child(confirm_no)
	
	# ---------------- Confirm Delete Save Modal ----------------
	delete_confirm_modal = PanelContainer.new()
	delete_confirm_modal.position = Vector2(400, 240)
	delete_confirm_modal.size = Vector2(480, 260)
	delete_confirm_modal.add_theme_stylebox_override("panel", modal_box.duplicate())
	delete_confirm_modal.visible = false
	add_child(delete_confirm_modal)
	
	var del_vbox = VBoxContainer.new()
	del_vbox.add_theme_constant_override("separation", 14)
	delete_confirm_modal.add_child(del_vbox)
	
	del_vbox.add_child(styled_label("PERMANENTLY DELETE SAVE?", 17, Color("ff5e6c")))
	var del_msg = styled_label(
		"Are you sure you want to delete your save file?\n" +
		"This will erase your saved character, items, and tower progress from disk.\n\n" +
		"This cannot be undone.",
		13,
		Color("dce7ea")
	)
	del_vbox.add_child(del_msg)
	
	var del_row = HBoxContainer.new()
	del_row.add_theme_constant_override("separation", 10)
	del_vbox.add_child(del_row)
	
	var del_yes = styled_button("DELETE SAVE PERMANENTLY", func():
		if game and game.sound_enabled: game.tone("hurt")
		SaveManager.delete_save()
		close_modals()
		refresh_save_status()
		refresh_options()
	)
	del_yes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	del_row.add_child(del_yes)
	
	var del_no = styled_button("CANCEL", func():
		close_modals()
		on_options_pressed()
	)
	del_no.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	del_row.add_child(del_no)
	
	build_keybinds_modal(modal_box)

func build_keybinds_modal(modal_box: StyleBoxFlat):
	keybinds_modal = PanelContainer.new()
	keybinds_modal.position = Vector2(280, 45)
	keybinds_modal.size = Vector2(720, 710)
	keybinds_modal.add_theme_stylebox_override("panel", modal_box.duplicate())
	keybinds_modal.visible = false
	add_child(keybinds_modal)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	keybinds_modal.add_child(vbox)
	
	vbox.add_child(styled_label("CUSTOMIZE KEYBOARD CONTROLS", 18, Color("7fead4")))
	vbox.add_child(styled_label("Click any action button below to rebind, then press a key. Esc cancels.", 12, Color("8ba8af")))
	
	keybinds_status_lbl = styled_label("", 12, Color("ffe28a"))
	vbox.add_child(keybinds_status_lbl)
	
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(670, 460)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)
	
	keybinds_grid = GridContainer.new()
	keybinds_grid.columns = 2
	keybinds_grid.add_theme_constant_override("h_separation", 24)
	keybinds_grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(keybinds_grid)
	
	var b_row = HBoxContainer.new()
	b_row.add_theme_constant_override("separation", 12)
	vbox.add_child(b_row)
	
	var reset_btn = styled_button("RESET TO DEFAULT KEYBINDINGS", func():
		if game:
			game.reset_keybinds()
			keybinds_rebinding_action = ""
			refresh_keybinds_modal()
	)
	reset_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b_row.add_child(reset_btn)
	
	var back_btn = styled_button("RETURN TO OPTIONS [ESC]", func():
		keybinds_rebinding_action = ""
		keybinds_modal.visible = false
		state = "options"
		options_modal.visible = true
	)
	back_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b_row.add_child(back_btn)

func refresh_keybinds_modal():
	if not is_instance_valid(keybinds_grid): return
	for child in keybinds_grid.get_children():
		child.queue_free()
	
	if keybinds_rebinding_action != "":
		keybinds_status_lbl.text = ">>> LISTENING: PRESS ANY KEY TO BIND [%s] (ESC TO CANCEL) <<<" % keybinds_rebinding_action.to_upper()
	else:
		keybinds_status_lbl.text = "Mouse: Left-Click moves & attacks with weapon · Right-Click casts assigned active skill"
	
	var actions = [
		["move_up", "Move Forward / Up"],
		["move_down", "Move Backward / Down"],
		["move_left", "Move Left"],
		["move_right", "Move Right"],
		["attack", "Physical Attack (Melee/Weapon)"],
		["interact", "Interact / Loot Drops"],
		["potion_life", "Drink Life Potion"],
		["potion_mana", "Drink Mana Potion"],
		["character", "Character Sheet"],
		["inventory", "Inventory Grid"],
		["skills", "Skill Matrix & Spells"],
		["map", "Tower Map"],
		["wormhole", "Wormhole Portal"],
		["system", "Pause / System Menu"]
	]
	
	for entry in actions:
		var act_id = entry[0]
		var act_label = entry[1]
		var row = HBoxContainer.new()
		row.custom_minimum_size = Vector2(320, 32)
		row.add_theme_constant_override("separation", 8)
		keybinds_grid.add_child(row)
		
		var lbl = styled_label(act_label + ":", 12, Color("c6d5d5"))
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lbl)
		
		var current_key = game.get_key_name(act_id) if game else "NONE"
		var btn_text = "[ PRESS KEY... ]" if keybinds_rebinding_action == act_id else "[ %s ]" % current_key
		var btn = styled_button(btn_text, func(aid = act_id):
			keybinds_rebinding_action = aid
			refresh_keybinds_modal()
		)
		btn.custom_minimum_size = Vector2(120, 30)
		row.add_child(btn)

func on_keybinds_pressed():
	if game and game.sound_enabled: game.tone("equip")
	state = "keybinds"
	keybinds_rebinding_action = ""
	options_modal.visible = false
	keybinds_modal.visible = true
	refresh_keybinds_modal()

func show_menu():
	state = "menu"
	splash_layer.visible = false
	menu_layer.visible = true
	visible = true
	close_modals()
	refresh_save_status()
	refresh_options()

func refresh_save_status():
	var has_save = SaveManager.has_save()
	if has_save:
		var summary = SaveManager.read_summary()
		var area_title = summary.get("area_name", "Garage Refuge")
		continue_button.disabled = false
		continue_button.text = "CONTINUE GAME [ENTER]"
		continue_badge.text = "SAVED: LEVEL %d · %d Si · %s" % [summary.get("level", 1), summary.get("silicon", 80), area_title]
		continue_badge.visible = true
		if is_instance_valid(confirm_msg):
			confirm_msg.text = (
				"An active save was found on disk:\n" +
				"Level %d · %d Silicon · %s\n\n" +
				"Starting a new game will overwrite your saved character\n" +
				"and Tower progress.\n\n" +
				"Are you sure you want to start a new game?"
			) % [summary.get("level", 1), summary.get("silicon", 80), area_title]
	else:
		continue_button.disabled = true
		continue_button.text = "CONTINUE GAME (NO SAVE DATA)"
		continue_badge.text = ""
		continue_badge.visible = false
		if is_instance_valid(confirm_msg):
			confirm_msg.text = "Start a fresh game?"

func refresh_options():
	if not game: return
	if is_instance_valid(resolution_button):
		resolution_button.text = "GRAPHICS SCALE: CRISP 1280x800" if game.crisp_graphics else "GRAPHICS SCALE: RETRO 640x400"
	if is_instance_valid(msaa_button):
		msaa_button.text = "ANTI-ALIASING (MSAA 3D): " + game.msaa_name()
	if is_instance_valid(display_button):
		display_button.text = "DISPLAY MODE: FULLSCREEN [F11]" if game.is_fullscreen() else "DISPLAY MODE: WINDOWED [F11]"
	if is_instance_valid(crt_button):
		crt_button.text = "CRT SCANLINES: ON [F]" if game.effects_enabled else "CRT SCANLINES: OFF [F]"
	if is_instance_valid(sound_button):
		sound_button.text = "AUDIO SFX: ON [M]" if game.sound_enabled else "AUDIO SFX: OFF [M]"
	if is_instance_valid(seed_field):
		seed_field.value = game.run_seed
	if is_instance_valid(save_info_label):
		if SaveManager.has_save():
			var summary = SaveManager.read_summary()
			var area_title = summary.get("area_name", "Garage Refuge")
			save_info_label.text = "Active Save: Level %d · %d Silicon · %s\nPath: %s" % [
				summary.get("level", 1),
				summary.get("silicon", 80),
				area_title,
				OS.get_user_data_dir() + "/arclight_save.json"
			]
			delete_save_button.disabled = false
			delete_save_button.text = "DELETE SAVE FILE..."
		else:
			save_info_label.text = "No active save file on disk.\nNew games will create: %s" % (OS.get_user_data_dir() + "/arclight_save.json")
			delete_save_button.disabled = true
			delete_save_button.text = "NO SAVE FILE TO DELETE"

func on_continue_pressed():
	if game:
		if game.sound_enabled: game.tone("equip")
		hide_all()
		game.continue_game()

func on_new_game_pressed():
	if game:
		if game.sound_enabled: game.tone("equip")
		if SaveManager.has_save():
			state = "confirm"
			modal_backdrop.visible = true
			confirm_modal.visible = true
		else:
			start_fresh_game()

func start_fresh_game():
	hide_all()
	if game:
		game.full_reset(true)
		game.begin()

func on_options_pressed():
	if game and game.sound_enabled: game.tone("equip")
	state = "options"
	refresh_options()
	modal_backdrop.visible = true
	options_modal.visible = true

func on_credits_pressed():
	if game and game.sound_enabled: game.tone("equip")
	state = "credits"
	modal_backdrop.visible = true
	credits_modal.visible = true

func on_quit_pressed():
	if game and game.sound_enabled: game.tone("equip")
	get_tree().quit()

func close_modals():
	state = "menu"
	keybinds_rebinding_action = ""
	if is_instance_valid(modal_backdrop): modal_backdrop.visible = false
	if is_instance_valid(options_modal): options_modal.visible = false
	if is_instance_valid(keybinds_modal): keybinds_modal.visible = false
	if is_instance_valid(credits_modal): credits_modal.visible = false
	if is_instance_valid(confirm_modal): confirm_modal.visible = false
	if is_instance_valid(delete_confirm_modal): delete_confirm_modal.visible = false

func hide_all():
	if is_instance_valid(video_player):
		video_player.stop()
	visible = false
	splash_layer.visible = false
	menu_layer.visible = false
	close_modals()
