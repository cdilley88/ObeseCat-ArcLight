extends SceneTree

const Game = preload("res://scripts/main.gd")
const TitleScreen = preload("res://scripts/title_screen.gd")
const SaveManager = preload("res://scripts/save_manager.gd")
const TEST_SAVE_PATH = "user://test_title_save.json"

var checks = 0
var failures = 0

func check(ok: bool, why: String):
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + why)

func _initialize():
	call_deferred("run")

func run():
	# Ensure test save path and settings start clean
	SaveManager.delete_save(TEST_SAVE_PATH)
	Game.delete_settings()
	check(not SaveManager.has_save(TEST_SAVE_PATH), "clean test save environment")
	
	# Test 1: Verify assets presence and validity
	check(ResourceLoader.exists("res://assets/video/its_presents_arclight.ogv"), "its_presents_arclight.ogv exists in assets")
	var video_res = load("res://assets/video/its_presents_arclight.ogv")
	check(video_res != null, "its_presents_arclight.ogv loads successfully")
	check(video_res is VideoStreamTheora, "video resource is VideoStreamTheora")
	
	check(ResourceLoader.exists("res://assets/ui/arclight_logo.png"), "arclight_logo.png exists in assets")
	var logo_res = load("res://assets/ui/arclight_logo.png")
	check(logo_res != null, "arclight_logo.png loads successfully")
	check(logo_res.get_width() > 1000 and logo_res.get_height() > 500, "arclight_logo.png has expected high resolution")
	
	# Test 2: Standalone TitleScreen instantiation & state transitions
	var title = TitleScreen.new()
	root.add_child(title)
	await process_frame
	
	check(title.splash_layer != null, "splash_layer created")
	check(title.menu_layer != null, "menu_layer created")
	check(title.modal_backdrop != null, "modal_backdrop created")
	check(title.continue_button != null, "continue_button created")
	check(title.new_game_button != null, "new_game_button created")
	check(title.options_button != null, "options_button created")
	check(title.credits_button != null, "credits_button created")
	check(title.quit_button != null, "quit_button created")
	
	# Verify terminology
	check(title.new_game_button.text == "NEW GAME", "new game button text is NEW GAME")
	check(title.continue_button.text.begins_with("CONTINUE GAME"), "continue button text begins with CONTINUE GAME")
	
	# In headless mode, splash automatically advances to menu
	check(title.state == "menu", "headless mode automatically enters menu state")
	check(title.menu_layer.visible, "menu_layer is visible")
	check(not title.splash_layer.visible, "splash_layer is hidden in menu state")
	check(not title.modal_backdrop.visible, "modal_backdrop is initially hidden")
	
	# Test 3: Modals (Options, Credits, Confirm)
	title.on_options_pressed()
	check(title.state == "options", "state transitions to options")
	check(title.options_modal.visible, "options modal visible")
	check(title.modal_backdrop.visible, "modal_backdrop visible during options")
	check(title.save_info_label != null, "save_info_label present in options")
	check(title.delete_save_button != null, "delete_save_button present in options")
	check(title.resolution_button != null, "resolution_button present in options")
	check(title.msaa_button != null, "msaa_button present in options")
	check(title.display_button != null, "display_button present in options")
	
	# Keybinds modal transition from options
	check(title.keybinds_modal != null, "keybinds_modal present")
	title.on_keybinds_pressed()
	check(title.state == "keybinds", "state transitions to keybinds")
	check(title.keybinds_modal.visible, "keybinds modal visible")
	check(not title.options_modal.visible, "options modal hidden when keybinds open")
	check(title.keybinds_grid.get_child_count() == 14, "keybinds grid populated with 14 actions")
	
	title.close_modals()
	check(title.state == "menu", "closing options/keybinds returns to menu")
	check(not title.options_modal.visible, "options modal hidden")
	check(not title.keybinds_modal.visible, "keybinds modal hidden")
	check(not title.modal_backdrop.visible, "modal_backdrop hidden after close")
	
	title.on_credits_pressed()
	check(title.state == "credits", "state transitions to credits")
	check(title.credits_modal.visible, "credits modal visible")
	check(title.modal_backdrop.visible, "modal_backdrop visible during credits")
	
	# Verify credits scroll & label sizing (prevent 1-character wrapping bug)
	var scroll = null
	if title.credits_modal.get_child_count() > 0:
		for c in title.credits_modal.get_child(0).get_children():
			if c is ScrollContainer:
				scroll = c
				break
	check(scroll != null, "credits scroll container found")
	if scroll and scroll.get_child_count() > 0:
		var text_label = scroll.get_child(0)
		check(text_label is Label, "intel_text is Label")
		check(text_label.custom_minimum_size.x >= 450, "intel_text has wide custom_minimum_size.x to prevent narrow wrap")
		check(text_label.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART, "intel_text has autowrap enabled")
	
	title.close_modals()
	check(title.state == "menu", "closing credits returns to menu")
	check(not title.credits_modal.visible, "credits modal hidden")
	
	title.queue_free()
	await process_frame
	
	# Test 4: Full Game integration (Boot -> Title -> Begin -> Return to Title)
	var game = Game.new()
	game.run_seed = 98765
	game.sound_enabled = false
	root.add_child(game)
	await process_frame
	await physics_frame
	
	check(not game.started, "game boots with started == false")
	check(is_instance_valid(game.hud), "hud exists")
	check(is_instance_valid(game.hud.title_screen), "hud has title_screen instance")
	check(game.hud.title_screen.visible, "title_screen is visible on boot")
	check(not game.hud.life_orb.visible, "life orb hidden on title screen")
	check(not game.hud.mana_orb.visible, "mana orb hidden on title screen")
	check(not game.hud.bottom_bar.visible, "bottom bar hidden on title screen")
	
	# Start game
	game.begin()
	await process_frame
	await physics_frame
	
	check(game.started, "game.begin() sets started == true")
	check(not game.hud.title_screen.visible, "title screen hidden during gameplay")
	check(game.hud.life_orb.visible, "life orb visible during gameplay")
	check(game.hud.mana_orb.visible, "mana orb visible during gameplay")
	check(game.hud.bottom_bar.visible, "bottom bar visible during gameplay")
	check(game.hud.objective.visible, "objective visible during gameplay")
	
	# Return to title screen
	game.return_to_title()
	await process_frame
	await physics_frame
	
	check(not game.started, "return_to_title() resets started to false")
	check(game.hud.title_screen.visible, "title screen restored")
	check(not game.hud.life_orb.visible, "life orb hidden after returning to title")
	check(not game.hud.bottom_bar.visible, "bottom bar hidden after returning to title")
	check(game.hud.title_screen.continue_button != null, "continue button present on title screen")
	
	# Verify graphics options & methods
	check(game.crisp_graphics == true, "game defaults to crisp graphics")
	check(game.msaa_level == Viewport.MSAA_4X, "game defaults to 4x MSAA")
	check(game.msaa_name() == "4X", "msaa_name returns 4X")
	game.toggle_resolution()
	check(game.crisp_graphics == false, "toggle_resolution sets crisp_graphics to false")
	check(game.holder.stretch_shrink == 2, "retro mode sets stretch_shrink = 2")
	game.toggle_resolution()
	check(game.crisp_graphics == true, "toggle_resolution restores crisp_graphics to true")
	check(game.holder.stretch_shrink == 1, "crisp mode sets stretch_shrink = 1")
	game.cycle_msaa()
	check(game.msaa_level == Viewport.MSAA_8X, "cycle_msaa advances 4X to 8X")
	game.cycle_msaa()
	check(game.msaa_level == Viewport.MSAA_DISABLED, "cycle_msaa advances 8X to DISABLED")
	check(game.msaa_name() == "OFF", "msaa_name returns OFF")
	
	# Clean up
	Game.delete_settings()
	game.queue_free()
	await process_frame
	
	print("--- Title and Opening Sequence Test Results ---")
	print("Checks passed: %d / %d" % [checks - failures, checks])
	print("Failures: %d" % failures)
	
	if failures > 0:
		push_error("Title checks failed!")
		quit(1)
	else:
		print("ALL TITLE AND OPENING TESTS PASSED.")
		quit(0)
