extends SubViewportContainer
## Independent fitting-room scene; shares model builder, never the world actor.
const Models = preload("res://scripts/models.gd")
var view: SubViewport
var model: Node3D
var game
var phase = 0.0
var revision = 0
var mode = "paws"

func setup(owner_game):
	game = owner_game
	custom_minimum_size = Vector2(313,258)
	stretch = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	view = SubViewport.new()
	view.size = Vector2i(626,540)
	view.own_world_3d = true
	view.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
	view.handle_input_locally = false
	add_child(view)
	var scene = Node3D.new()
	view.add_child(scene)
	var environment = WorldEnvironment.new()
	var settings = Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color("0b151e")
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color("adcacb")
	settings.ambient_light_energy = 0.65
	environment.environment = settings
	scene.add_child(environment)
	var key = DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-40,-30,0)
	key.light_color = Color("ffe0b4")
	key.light_energy = 1.4
	scene.add_child(key)
	var rim = DirectionalLight3D.new()
	rim.rotation_degrees = Vector3(-25,145,0)
	rim.light_color = Color("77dfd7")
	rim.light_energy = 0.65
	scene.add_child(rim)
	var camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 3.8
	camera.position = Vector3(3,2.5,4)
	scene.add_child(camera)
	camera.look_at(Vector3(0,0.8,0))
	camera.current = true
	Models.cylinder(scene,Vector3(0,-0.12,0),1.4,0.12,Color("243740"))
	Models.ring(scene,1.4,Color("4d8789"))
	model = Models.pet()
	scene.add_child(model)
	model.rotation.y = -2.2

func refresh():
	if not is_instance_valid(model) or game.equipment.is_empty(): return
	Models.equip(model,game.equipment)
	mode = game.equipment.locomotion.get("mode","paws")
	revision += 1

func turn(amount: float):
	model.rotation.y += amount

func _process(delta):
	if not is_instance_valid(model) or not is_visible_in_tree(): return
	phase += delta
	model.position.y = 0.22+sin(phase*3)*0.06 if mode == "hover" else sin(phase*2)*0.012
	model.get_node("Tail").rotation.z = sin(phase*2)*0.15
