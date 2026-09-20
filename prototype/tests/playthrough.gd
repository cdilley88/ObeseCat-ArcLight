extends SceneTree
## Drives normal game commands through real physics frames. No combat stat overrides.
const Game = preload("res://scripts/main.gd")
var game
var failed = false

func _initialize():
	call_deferred("run")

func run():
	game = Game.new()
	game.run_seed = 170126
	root.add_child(game)
	game.start_run()
	game.sound_enabled = false
	game.begin()
	for enemy in game.enemies:
		if enemy.hp <= 0: continue
		var click = InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.pressed = true
		click.position = game.camera.unproject_position(enemy.node.position + Vector3(0, 0.65, 0)) * Vector2(root.get_visible_rect().size) / Vector2(game.viewport.size)
		game._unhandled_input(click)
		var frames = 0
		while enemy.hp > 0 and game.hp > 0 and frames < 1500:
			await physics_frame
			frames += 1
			if game.hp < 45 and game.potions.life > 0:
				var heal = InputEventKey.new()
				heal.physical_keycode = KEY_Z
				heal.pressed = true
				game._unhandled_input(heal)
		print("Encounter ", enemy.index, ": enemy HP ", enemy.hp, ", player HP ", game.hp, ", frames ", frames)
		if enemy.hp > 0:
			failed = true
			break
	for contact in game.interactables.duplicate():
		if contact.role == "chest" and contact.chest.kind == 3:
			game.player.position = contact.node.position
			game.interact(contact)
	# Recover loot after the combat area is safe, through normal pathing/pickup.
	if game.hp > 0:
		for drop in game.drops.duplicate():
			game.target_drop = drop
			game.path = game.make_path(game.player.position,drop.node.position)
			for step in range(450):
				if not game.drops.has(drop) or game.hp <= 0: break
				await physics_frame

	print("PLAYTHROUGH: clear=", game.won, " HP=", game.hp, " inventory=", game.inventory.size())
	print("PROGRESSION: level=", game.progression.level, " points=", game.progression.points, " XP=", game.progression.xp)
	if game.progression.level != 2 or game.progression.points != 5: failed = true
	if not game.won or game.inventory.size() < 2 or game.inventory.size() > 6: failed = true
	game.paused = true
	if DisplayServer.get_name() != "headless":
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://../artifacts/40-lobby-clear.png")
	game.travel_zone("hub")
	print("RETURN: area=",game.area," Silicon=",game.silicon," level=",game.progression.level)
	if game.area != "hub" or game.silicon < 110 or game.progression.level != 2: failed = true
	game.queue_free()
	await process_frame
	quit(1 if failed else 0)
