extends Node3D

#var move_speed: float = 10.0
var move_speed: float = 25.0 # 15.0 is good for default
var zoom_speed: float = 2.0
var min_zoom: float = 5.0
var max_zoom: float = 50.0
var edge_scroll_speed: float = 10.0
var edge_scroll_margin: int = 20
var ui_script
var camera: Camera3D
var dragging: bool = false
var last_mouse_pos: Vector2
var max_drag_distance: float = 100

var food = 100
var wood = 0
var ore = 0
var units = 0
var health = 100
var max_units = 5

var attack_mode = 0 # 0 defensive 1 offensive

var resource_timer: float = 0.0     # Current time
var resource_interval: float = 60.0 # Interval for automatic resources
var food_inc: int = 10              # Food increment amount
var wood_inc: int = 10              # Wood increment amount
var ore_inc: int = 10               # Ore increment amount

func can_buy(resource: String, y: int, isBuilding : bool):
	if(script.isfree == true):
		return true
	if(units >= max_units && !isBuilding):
		return false
	var x = 0
	if(resource == "food"):
		x = food
	if(resource == "wood"):
		x = wood
	if(resource == "ore"):
		x = ore	
	if(x - y >= 0):
		return true
	return false
			
func consume_resouce(resource,amount):
	if(resource == "food"):
		food -= amount
	if(resource == "wood"):
		wood -= amount
	if(resource == "ore"):
		ore -= amount
	update_ui()

func attack_mode_clicked(x):
	attack_mode = x

func update_resources(decrement: bool, resource: String, amount: int) -> void:
	if resource == "food":
		food = clamp(food - amount if decrement else food + amount, 0, 500)
	elif resource == "wood":
		wood = clamp(wood - amount if decrement else wood + amount, 0, 500)
	elif resource == "ore":
		ore = clamp(ore - amount if decrement else ore + amount, 0, 500)
	update_ui()

func update_ui():
	var enemy_health = $EnemyManager.health
	$"../Control".update_ui_text(food,wood,ore,units,health,enemy_health,max_units)

func _ready() -> void:
	ui_script = get_node("../Control")
	camera = $Camera3D
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta: float) -> void:
	generate_resources(delta)
	
	if(health <= 0):
		$"../Control".end_game(false)
	handle_camera_movement(delta)
	handle_zoom(delta)
	clamp_x_y()

# Generates resources every x amount of seconds
func generate_resources(delta: float) -> void:
	resource_timer += delta
	if resource_timer >= resource_interval:
		resource_timer = 0.0
		food = min(food + food_inc, 500)
		wood = min(wood + wood_inc, 500)
		ore = min(ore + ore_inc, 500)
		update_ui()

func handle_camera_movement(delta: float) -> void:
	if Input.is_action_just_pressed("f_one"):
		$"../Control".visible = !$"../Control".visible
	
	if Input.is_action_pressed("lmb_hold") && ui_script.current_action == 0 && ui_script.isInUI == false:
		var mouse_pos = get_viewport().get_mouse_position()
		if dragging:
			var mouse_delta = mouse_pos - last_mouse_pos
			
			if mouse_delta.length() > max_drag_distance:
				mouse_delta = mouse_delta.normalized() * max_drag_distance
			
			mouse_delta *= move_speed * delta * 0.1

			position -= camera.global_transform.basis.x * mouse_delta.x
			position += _get_flat_forward() * mouse_delta.y 
		
		last_mouse_pos = mouse_pos
		dragging = true
	else:
		dragging = false


	var movement = Vector3.ZERO
	if Input.is_action_pressed("w_key"):
		movement += _get_flat_forward() 
	if Input.is_action_pressed("s_key"):
		movement -= _get_flat_forward()
	if Input.is_action_pressed("a_key"):
		movement -= camera.global_transform.basis.x
	if Input.is_action_pressed("d_key"):
		movement += camera.global_transform.basis.x 
	
	if movement != Vector3.ZERO:
		movement = movement.normalized() * move_speed * delta
		position += movement

func handle_zoom(delta: float) -> void:
	var zoom_dir = 0 

	if Input.is_action_just_pressed("scroll_up"):
		zoom_dir = -1
	elif Input.is_action_just_pressed("scroll_down"):
		zoom_dir = 1

	if zoom_dir != 0:
		var zoom_vector = camera.global_transform.basis.z * zoom_speed * zoom_dir
		var new_camera_position = camera.position + zoom_vector

		if new_camera_position.y <= min_zoom and zoom_dir == -1:
			position += _get_flat_forward() * zoom_speed * 0.5
		elif new_camera_position.y >= max_zoom and zoom_dir == 1:
			position -= _get_flat_forward() * zoom_speed * 0.5
		else:
			camera.position = new_camera_position
			camera.position.y = clamp(camera.position.y, min_zoom, max_zoom)
			camera.position.y = clamp(camera.position.y, min_zoom, max_zoom)

func _get_flat_forward() -> Vector3:
	var forward = -camera.global_transform.basis.z 
	forward.y = 0
	return forward.normalized()

func clamp_x_y():

	position.x = clamp(position.x, -50, 50)
	position.z = clamp(position.z, -50, 50)

	camera.position.x = clamp(camera.position.x, -50, 50)
	camera.position.z = clamp(camera.position.z, -50, 50)


func set_move_speed(value: float) -> void:
	move_speed = value

func set_zoom_speed(value: float) -> void:
	zoom_speed = value
