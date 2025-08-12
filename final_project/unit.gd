extends CharacterBody3D

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D

var unit_type = 0 # 0,1,2,3,4,5 // farmer,lumber,miner,knight,mace,mage
var friendly = 0 # 0 friendly, 1 enemey
var town_hall_positions = [44,-44] # 0 is friendly, 1 is enemy pos
var resource_count = 0
var health = 100
func _ready() -> void:

	
	pass

var farm_m = preload("res://Models/Knight/M_Farmer.tres")
var lumber_m = preload("res://Models/Knight/M_Lumber.tres")
var miner_m = preload("res://Models/Knight/M_Miner.tres")
var knight_m = preload("res://Models/Knight/M_Knight.tres")
var mace_m = preload("res://Models/Knight/M_Mace.tres")


var timer: float = 0.0
var doonce = true
func _process(delta: float) -> void:
	if(health <= 0):
		if(doonce && friendly == 0):
			doonce = false
			$"../../Player".units -= 1
		queue_free()
		$"../../Player".update_ui()
	timer += delta 
	if timer >= 5.0: 
		five_second_update()
		timer = 0.0  
		
var crop_to_go_to = null

	
func move_to_random_defensive():
		var random_position := Vector3.ZERO
		if(friendly == 0):
			random_position.x = randf_range(-25.0, 25.0)
			random_position.z = randf_range(0.0, 50.0)
		if(friendly == 1):
			random_position.x = randf_range(-25.0, 25.0)
			random_position.z = randf_range(0.0, -50.0)
		nav_agent.set_target_position(random_position)
		$CollisionShape3D/AnimationPlayer.play("Armature|Run")
		
func move_to_attack():
		
		var random_position := Vector3.ZERO
		if(friendly == 0):
			random_position.z = -43.0
		else:
			random_position.z = 43.0
		nav_agent.set_target_position(random_position)
		$CollisionShape3D/AnimationPlayer.play("Armature|Run")
		

func five_second_update() -> void:
	if(unit_type == 0):
		if(crop_to_go_to == null || $"../../Player/BuildingManager".has_crop(crop_to_go_to) == false):
			crop_to_go_to = $"../../Player/BuildingManager".get_random_crop()
			if(crop_to_go_to != null):
				var target_position = crop_to_go_to.global_position 
				update_target_position(target_position.x, target_position.z)
			else:
				update_target_position(0, town_hall_positions[friendly])
	if(unit_type > 2):
		if(unit_to_attack != null):
			unit_to_attack.health -= 50
			

func collided_with_farm(farm_node):
	if(unit_type == 0):
		play_anim(2)
		resource_count += farm_node.resource_count
		$"../../Player/BuildingManager".remove_crop(farm_node)
		await get_tree().create_timer(5.0).timeout
		$CollisionShape3D/AnimationPlayer.play("Armature|Run")
		crop_to_go_to = null
		update_target_position(0, town_hall_positions[friendly])
		
		
	


func init_vars(unit, t):
	unit_type = unit
	friendly = t
	if(unit_type == 0):
	
		five_second_update()
		pass
	if(unit_type == 1):
	
		pass
	if(unit_type == 2):
	
		pass
	if(unit_type == 3):
		pass
		
	if(unit_type == 4):
		pass
	
	
var tree_positions = [[-51,12],[-53,1],[-53,-8],[-58,-3],[-58,4],[-58,14],[-55,17]]
var rock_positions = [[53,23],[57,17],[52,8],[61,8],[57,0],[61,-4],[59,-14],[52,-9]]
func go_to_tree():
	var random_index = randi() % tree_positions.size()
	var pos = tree_positions[random_index]
	update_target_position(pos[0], pos[1])
	$CollisionShape3D/AnimationPlayer.play("Armature|Run")
	
func go_to_rock():
	var random_index = randi() % rock_positions.size()
	var pos = rock_positions[random_index]
	update_target_position(pos[0], pos[1])
	$CollisionShape3D/AnimationPlayer.play("Armature|Run")
	
func collided_with_rock():
	if unit_type == 2:
		if(resource_count == 0):
			play_anim(2)
		await get_tree().create_timer(5.0).timeout
		$CollisionShape3D/AnimationPlayer.play("Armature|Run")
		update_target_position(0, town_hall_positions[friendly])
		resource_count += 10
		if(resource_count > 100):
			resource_count = 100



func collided_with_tree():
	print("ttt")
	if unit_type == 1:
		if(resource_count == 0):
			play_anim(2)
		await get_tree().create_timer(5.0).timeout
		$CollisionShape3D/AnimationPlayer.play("Armature|Run")
		update_target_position(0, town_hall_positions[friendly])
		resource_count += 10
	
func collided_with_town():
	if unit_type == 1:
		go_to_tree()
		if(friendly == 0):
			$"../../Player".update_resources(false,"wood",resource_count)
	if unit_type == 2:
		go_to_rock()
		if(friendly == 0):
			$"../../Player".update_resources(false,"ore",resource_count)
	if(unit_type == 0):
		crop_to_go_to = null
		$CollisionShape3D/AnimationPlayer.play("Armature|Run")
		if(friendly == 0):
			$"../../Player".update_resources(false,"food",resource_count)
		
	resource_count = 0
	
	if(friendly == 1 && global_transform.origin.z > 0):
		$"../../Player".health -= 10
		if($"../../Player".health < 0):
			$"../../Player".health = 0
		$"../../Player".update_ui()
		health = 0
	if(friendly == 0 && global_transform.origin.z < 0):
		$"../../Player/EnemyManager".health -= 10
		if($"../../Player/EnemyManager".health < 0):
			$"../../Player/EnemyManager".health = 0
		$"../../Player".update_ui()
		health = 0
		
		

func play_anim(x): # 0 is idle, 1 is run, 2 is attack
	if(x == 0):
		$CollisionShape3D/AnimationPlayer.play("Armature|Idle")
	if(x == 1):
		$CollisionShape3D/AnimationPlayer.play("Armature|Run")
	if(x == 2):
		$CollisionShape3D/AnimationPlayer.play("Armature|Attack")

func move_to_random():
		var random_position := Vector3.ZERO
		random_position.x = randf_range(-50.0, 50.0)
		random_position.z = randf_range(-50.0, 50.0)
		nav_agent.set_target_position(random_position)
		
func update_target_position(x,z):
	var new_pos := Vector3.ZERO
	new_pos.x = x
	new_pos.z = z
	nav_agent.set_target_position(new_pos)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("four_key"):
		move_to_random()
		$CollisionShape3D/AnimationPlayer.play("Armature|Attack")

	if event.is_action_pressed("five_key"):
		$CollisionShape3D/AnimationPlayer.play("Armature|Idle")
func _physics_process(delta: float) -> void:

	var destination = nav_agent.get_next_path_position()
	var local_destination = destination - global_position
	var direction = local_destination.normalized()
	

	if local_destination.length() > 1:
		velocity = direction * 5.0
		


		var target_rotation = atan2(direction.x, direction.z) 
		rotation.y = lerp_angle(rotation.y, target_rotation, 0.1) 
		if($CollisionShape3D/AnimationPlayer.current_animation == "Armature|Run" || $CollisionShape3D/AnimationPlayer.current_animation == "Armature|Idle"):
			$CollisionShape3D/AnimationPlayer.play("Armature|Run")
	
	else:
		velocity = Vector3.ZERO 
		if($CollisionShape3D/AnimationPlayer.current_animation == "Armature|Run"):
			$CollisionShape3D/AnimationPlayer.play("Armature|Idle")
			pass

		if(unit_type == 3 || unit_type == 4 || unit_type == 5):
			if(unit_to_attack == null):
				if($"../../Player".attack_mode == 0):
					move_to_random_defensive()
				else:
					move_to_attack()
			else:
				attack_unit()

	move_and_slide()
	



var unit_to_attack = null

func attack_unit():
	if(unit_to_attack != null):
		var target_position = unit_to_attack.global_position  
		update_target_position(target_position.x, target_position.z)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if(body.has_method("attack_unit")):
		print("collided")
		if(body.friendly != friendly):
			if(body.unit_type > 2):
				if(unit_to_attack == null):
					print("set attack")
					$CollisionShape3D/AnimationPlayer.play("Armature|Attack")
					unit_to_attack = body
					attack_unit()
	


func _on_audio_stream_player_3d_finished() -> void:

	$AudioStreamPlayer3D.pitch_scale = randf_range(0.8, 1.1)
