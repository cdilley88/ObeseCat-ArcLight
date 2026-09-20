extends SceneTree
## In-engine rendering/integration harness, not a manual playtest.
const Game = preload("res://scripts/main.gd")
var game

func _initialize():
	call_deferred("run")

func capture(filename: String):
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../artifacts/" + filename + ".png")

func run():
	game = Game.new()
	game.run_seed = 170126
	root.add_child(game)
	game.restart(false,false,"run")
	await create_timer(0.5).timeout
	await capture("01-entry")
	game.begin()
	game.paused = true
	await capture("02-factory")
	game.toggle_inventory()
	for i in range(game.inventory.size()):
		var item: Dictionary = game.inventory[i]
		if item.model == 1 and item.slot in ["matrix","barding","locomotion"]: game.equip_item(i)
	game.cycle_socket(0)
	game.cycle_socket(1)
	game.cycle_socket(2)
	game.hud.refresh_inventory()
	await capture("03-equipped")
	game.toggle_inventory()
	game.paused = true
	await capture("04-modular-gear")
	game.paused = false
	game.target_enemy = game.enemies[0]
	var start = game.player.position
	await create_timer(4.0).timeout
	print("RENDER SMOKE movement distance: ", game.player.position.distance_to(start))
	await capture("05-combat")
	game.paused = true
	game.add_to_backpack(game.Loot.signature_item(game.rng))
	game.equip_item(game.inventory.size() - 1)
	game.hud.selection = game.inventory.size() - 1
	game.inventory_open = true
	game.hud.refresh_inventory()
	game.camera.size = 15.0
	game.pet.rotation.y = -2.2
	await create_timer(0.6).timeout
	await capture("07-signature-inspection")
	game.queue_free()
	await process_frame
	quit()
