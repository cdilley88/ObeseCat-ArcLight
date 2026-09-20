extends SceneTree
const Game = preload("res://scripts/main.gd")

func _initialize():
	call_deferred("run")

func capture(filename: String):
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../artifacts/" + filename + ".png")

func run():
	var game = Game.new()
	game.run_seed = 170126
	root.add_child(game)
	game.restart(false,false,"run")
	game.sound_enabled = false
	game.begin()
	game.award_xp(50)
	game.toggle_character()
	await create_timer(0.3).timeout
	await capture("08-character-points")
	for attribute in ["strength", "dexterity", "vitality", "energy", "vitality"]:
		game.hud.attribute_buttons[attribute].pressed.emit()
	game.hp = 63
	game.mana = 22
	await capture("09-character-allocated")
	game.toggle_inventory()
	await capture("10-orbs-and-gear")
	game.queue_free()
	await process_frame
	quit()
