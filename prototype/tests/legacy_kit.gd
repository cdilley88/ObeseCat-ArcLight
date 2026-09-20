extends RefCounted
# Explicit old laboratory fixture for inventory and trading regression tests only.
static func install(game):
	game.inventory.clear()
	for slot in game.Loot.SLOTS: game.equipment[slot] = game.Loot.empty_item(slot)
	for kind in game.Loot.BASES:
		for base in range({"head":2,"neck":2,"barding":2,"harness":2,"matrix":2,"weapon":4,"locomotion":4}[kind]):
			var item = game.Loot.make_item(kind,base,game.rng,false)
			game.inventory.append(item)
			if base == 0: game.equipment["left" if kind == "weapon" else kind] = item
	game.Backpack.arrange(game.inventory,game.equipment)
	game.hp = game.current_stats().max_life
	game.mana = game.current_stats().max_mana

	game.Models.equip(game.pet,game.equipment)
	game.hud.refresh_inventory()
