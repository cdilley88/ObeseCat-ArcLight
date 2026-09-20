extends SceneTree
const Game = preload("res://scripts/main.gd")
var checks = 0
var failures = 0
func check(ok: bool, why: String):
	checks += 1
	if not ok: failures += 1; push_error(why)
func _initialize(): call_deferred("run")
func run():
	var g = Game.new()
	g.run_seed = 170126
	root.add_child(g)
	g.sound_enabled = false
	g.set_physics_process(false)
	g.begin()
	check(g.potions.life == 6 and g.potions.mana == 4,"starter supplies")
	check(not g.drink_potion("life") and g.potions.life == 6,"full life consumes nothing")
	g.hp = 10
	check(g.drink_potion("life") and g.hp == 50 and g.potions.life == 5,"life potion restores bounded amount")
	check(not g.drink_potion("life"),"potion cooldown prevents spam")
	g.mana = 1
	check(g.drink_potion("mana") and g.mana == 31 and g.potions.mana == 3,"mana potion has independent charge and cooldown")
	g.potion_cooldowns.life = 0
	g.paused = true
	check(not g.drink_potion("life"),"no paused consumption")
	g.paused = false
	g.hp = 0
	check(not g.drink_potion("life"),"potions cannot resurrect")
	g.hp = 10
	g.potions.life = 0
	check(not g.drink_potion("life"),"no empty consumption")
	check(g.add_potions("life",1000) == 99 and g.potions.life == 99,"stack cap")
	check(g.add_potions("life",1) == 0 and g.add_potions("fake",1) == 0,"overflow and invalid supplies")
	check(not g.buy_potion("mana") and not g.debug_action("potions"),"town actions require correct contact")
	g.menu_open = "weapons"
	g.silicon = 8
	check(g.buy_potion("mana") and g.silicon == 0,"vendor purchase exact price")
	check(not g.buy_potion("mana"),"insufficient funds")
	g.silicon = 100
	check(not g.buy_potion("life") and g.silicon == 100,"full stack purchase charges nothing")
	g.menu_open = "debug"
	check(g.debug_action("potions") and g.potions.life == 99 and g.potions.mana == 99,"debug maxes both supplies")
	check(g.debug_action("unlock") and g.keycards.size() == 19,"debug unlocks all main stops")
	g.close_contact()
	g.start_run()
	var origin = g.player.position
	check(g.cast_wormhole() and g.wormhole.area == "lobby","field cast records location")
	var portal_count = 0
	for entry in g.interactables:
		if entry.role == "wormhole": portal_count += 1
	check(portal_count == 1,"single field portal")
	g.hit_enemy(g.enemies[0],99999)
	var wallet = g.silicon
	check(g.use_wormhole() and g.area == "hub","portal travels home without clear")
	check(g.potions.life == 99 and g.silicon == wallet,"travel preserves supplies and currency")
	check(not g.make_path(g.player.position,Vector3(0,0,-3)).is_empty(),"garage return portal reachable")
	check(g.cast_wormhole() and g.area == "lobby" and g.player.position == origin,"B returns to exact origin from town")
	check(g.enemies[0].hp <= 0,"portal does not respawn defeated enemies")
	g.player.position += Vector3(1,0,0)
	check(g.cast_wormhole() and g.wormhole.pos == g.player.position,"recast replaces return location")
	g.use_wormhole()
	g.menu_open = "debug"
	check(g.debug_action("reset_waypoints") and g.keycards.is_empty() and g.zone_states.is_empty() and g.wormhole.is_empty(),"debug waypoint reset leaves no stale portal or cleared carrier")
	check(g.silicon == wallet and g.potions.life == 99,"debug waypoint reset keeps character supplies")
	g.close_contact()
	g.start_run()
	g.cast_wormhole()
	g.use_wormhole()
	g.new_sortie()
	check(g.wormhole.is_empty() and not g.cast_wormhole(),"new sortie invalidates return point")
	g.open_system()
	check(g.paused and g.menu_open == "system","system menu pauses")
	g.toggle_inventory()
	check(g.inventory_open and g.menu_open == "" and g.paused,"inventory switch preserves pause")
	g.restart(false)
	check(g.potions.life == 6 and g.potions.mana == 4 and g.wormhole.is_empty(),"full reset restores starter supplies")
	for binding in [[KEY_C,"character"],[KEY_I,"inventory"],[KEY_V,"tower"],[KEY_ESCAPE,"close"],[KEY_ESCAPE,"system"]]:
		var key = InputEventKey.new()
		key.physical_keycode = binding[0]
		key.pressed = true
		g._unhandled_input(key)
		match binding[1]:
			"character": check(g.character_open,"C hotkey")
			"inventory": check(g.inventory_open,"I hotkey")
			"tower": check(g.menu_open == "tower","V hotkey")
			"close": check(g.menu_open == "","Esc closes menu")
			"system": check(g.menu_open == "system" and g.paused,"Esc opens system")
	g.close_contact()
	g.hp = 1
	g.mana = 1
	for code in [KEY_Z,KEY_X]:
		var key = InputEventKey.new()
		key.physical_keycode = code
		key.pressed = true
		g._unhandled_input(key)
	check(g.potions.life == 5 and g.potions.mana == 3,"Z and X hotkeys")
	g.start_run()
	var key = InputEventKey.new()
	key.physical_keycode = KEY_B
	key.pressed = true
	g._unhandled_input(key)
	check(not g.wormhole.is_empty(),"B hotkey")
	print("SUPPLY/PORTAL CHECKS: ",checks," / failures: ",failures)
	g.queue_free()
	await process_frame
	quit(1 if failures else 0)

