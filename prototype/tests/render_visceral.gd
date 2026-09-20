extends SceneTree
const Game = preload("res://scripts/main.gd")
func _initialize(): call_deferred("run")
func capture(name: String):
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../artifacts/"+name+".png")
func run():
	var g = Game.new()
	root.add_child(g)
	g.sound_enabled = false
	g.set_physics_process(false)
	g.begin()
	g.inventory.clear()
	for kind in g.Loot.BASES:
		for base in range(g.Loot.BASES[kind].size()):
			if g.Loot.BASES[kind][base].get("affinity","") == "Visceral":
				g.add_to_backpack(g.Loot.make_item(kind,base,g.rng,false))
	for i in range(3):
		var choices = {"head":6+mini(i,1),"left":9+i}
		if i == 0: choices["right"] = 12
		for slot in choices:
			for index in range(g.inventory.size()):
				var item = g.inventory[index]
				if item.slot == ("weapon" if slot in ["left","right"] else slot) and item.model == choices[slot]:
					assert(g.equip_item(index,slot))
		g.Models.equip(g.pet,g.equipment)
		g.toggle_inventory()
		g.hud.refresh_inventory()
		await create_timer(0.3).timeout
		await capture("121-visceral-"+str(i))
		g.toggle_inventory()
	g.menu_open = "debug"
	g.hud.hub_menu.show_role("debug")
	await capture("122-affinity-debug")
	print("VISCERAL RENDER COMPLETE")
	quit()
