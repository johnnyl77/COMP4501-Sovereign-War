extends Node3D


const GRID_SIZE = 2.0  



var ui_script
var selectedBuildingIndex = 1
const BuildingClass = preload("res://building_class.gd")
var offsets = [
	Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1), 
	Vector2(-1, 0),   Vector2(0,0),              Vector2(1, 0), 
	Vector2(-1, 1), Vector2(0, 1), Vector2(1, 1)  
	]





var FARM_COST = 25
var HOUSE_COST = 50
var BARRACK_COST = 100
var WALL_COST = 100
var CASTLE_COST = 200
var XBOW_COST = 500





var buildings = [
	BuildingClass.new("../../Previews/SM_Preview1", "res://Models/Farm/sm_crop.tscn", [Vector2(0,0)],true, "food", FARM_COST), # farm
	BuildingClass.new("../../Previews/SM_Preview2", "res://Models/Hut/SM_Hut.tscn", [Vector2(-1, 0),       Vector2(0,0),          Vector2(1, 0)],true, "wood",HOUSE_COST), # quarry
	BuildingClass.new("../../Previews/SM_Preview3", "res://Models/Barracks/SM_Barracks.tscn", offsets,false,"wood",BARRACK_COST), # barrack
	BuildingClass.new("../../Previews/SM_Preview4", "res://Models/Wall/SM_Wall.tscn", [Vector2(0,0)],true,"ore",WALL_COST), # wall
	BuildingClass.new("../../Previews/SM_Preview5", "res://Models/Tower/SM_Tower.tscn", [Vector2(0,0)],true,"ore",CASTLE_COST), # corner
	BuildingClass.new("../../Previews/SM_Preview6", "res://Models/Ballista/SM_Ballista.tscn", [Vector2(0,0)],true,"ore",XBOW_COST) # ballista
]

var active_crop_stack: Dictionary = {}

func add_crop(new_building: Node) -> void:
	var instance_id = new_building.get_instance_id()
	active_crop_stack[instance_id] = new_building 
	print("Added crop:", new_building.name, "with ID:", instance_id)

func remove_crop(new_building: Node) -> void:
	var instance_id = new_building.get_instance_id()
	if active_crop_stack.has(instance_id):
		active_crop_stack.erase(instance_id)  
		print("Removed crop:", new_building.name, "with ID:", instance_id)
		
func has_crop(new_building: Node) -> bool:
	var instance_id = new_building.get_instance_id()
	return active_crop_stack.has(instance_id)  

func get_random_crop() -> Node:
	var keys = active_crop_stack.keys()
	
	while keys.size() > 0:
		var random_key = keys[randi() % keys.size()]
		var crop = active_crop_stack.get(random_key, null)
		
		if crop != null and is_instance_valid(crop):
			return crop
		else:
			active_crop_stack.erase(random_key)
			keys = active_crop_stack.keys()

	return null


@onready var previewMesh = $"../../Previews/SM_Preview1"
var sceneToPlace = buildings[selectedBuildingIndex].sceneToPlace
var resourceCost = [0, 0, 0]  # food, wood, ore
var building_map: Dictionary = {}

@onready var camera = get_viewport().get_camera_3d()
@onready var buildingParent = $"../../Buildings"
var buildRotation = 0 # 0, 90, 180, 270
func _ready() -> void:
	ui_script = get_node("../../Control")
	switch_building(selectedBuildingIndex)
	selectedBuildingIndex = -1

func hideAllPreviewMeshes():
	$"../../Previews/SM_Preview1".visible = false
	$"../../Previews/SM_Preview2".visible = false
	$"../../Previews/SM_Preview3".visible = false
	$"../../Previews/SM_Preview4".visible = false
	$"../../Previews/SM_Preview5".visible = false
	$"../../Previews/SM_Preview6".visible = false
func updatePreview():
	previewMesh = get_node(buildings[selectedBuildingIndex].previewMesh)

func enterDeleteMode():
	previewMesh.visible = false
	hideAllPreviewMeshes()
	pass


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("nine_key"):
		debug()
	
	# Deselects the current mesh and displays nothing so you can stop building
	if Input.is_action_just_pressed("esc_key") and ui_script.current_action == 1:
		selectedBuildingIndex = -1
		hideAllPreviewMeshes()
	
	if ui_script.current_action == 1 and previewMesh and selectedBuildingIndex != -1:
		move_preview_to_mouse()
		if(ui_script.isInUI):
			previewMesh.visible = false
		else:
			previewMesh.visible = true
		if Input.is_action_pressed("lmb_hold") and can_place_building():
			place_building()
		if Input.is_action_just_pressed("r_key"):
			if(buildings[selectedBuildingIndex].canRotate):
				buildRotation = (buildRotation + 90) % 360
				previewMesh.rotation_degrees.y = buildRotation
		if Input.is_action_just_pressed("ui_left"):
			switch_building((selectedBuildingIndex - 1) % buildings.size())
		if Input.is_action_just_pressed("ui_right"):
			switch_building((selectedBuildingIndex + 1) % buildings.size())
	if ui_script.current_action == 2:
		move_preview_to_mouse()
		if(ui_script.isInUI):
			previewMesh.visible = false
			return
		if Input.is_action_pressed("lmb_hold"):
			var base_position = previewMesh.global_transform.origin
			var key = Vector2i(base_position.x, base_position.z)
			remove_building(key)
			
		

func move_preview_to_mouse() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var space_state = get_world_3d().direct_space_state
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000

	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)

	if result:
		
		if(ui_script.current_action == 1):
			var position = result.position
			position = snap_to_grid(position)
			if position.x <= 48 and position.x >= -48 and position.z >= 1 and position.z <= 48:
				previewMesh.global_transform.origin = position
		elif(ui_script.current_action == 2):
			var position = result.position
			position = snap_to_grid(position)
			var key = Vector2i(position.x,position.z)
			if key in building_map:

				
				var secondMesh = get_node(buildings[building_map[key].building_index].previewMesh)
				if(secondMesh != previewMesh):
					previewMesh.visible = false
				previewMesh = secondMesh
				previewMesh.global_transform.origin.x = building_map[key].origin_cord[0]
				previewMesh.global_transform.origin.z = building_map[key].origin_cord[1]
				if(building_map[key].couldRotate):
					previewMesh.rotation_degrees.y = building_map[key].buildRotation
				previewMesh.visible = true
			else:
				previewMesh.visible = false
				
			
			
func remove_building(key) -> void:
	if key in building_map:

		if(building_map[key].building_index == 1):
			$"..".max_units -= 1
		if(building_map[key].building_index == 2):
			$"..".max_units -= 2
		$"..".update_ui()
		remove_crop(building_map[key])
		$"../../Control".playPlaceSound(true)
	

		var tiles = building_map[key].tiles_used.duplicate(true)  
		building_map[key].queue_free() 
		for tile in tiles:
			if tile in building_map:
				building_map.erase(tile)

		
	
		

		$"../../NavigationRegion3D".bake_navigation_mesh(true)
		
	else:
		pass
	previewMesh.visible = false
			
			
	
func snap_to_grid(position: Vector3) -> Vector3:
	position.x = snapped(position.x, GRID_SIZE)
	position.z = snapped(position.z, GRID_SIZE)
	position.y = 0
	return position

const RESTRICTED_X_RANGE = Vector2(5, -5)
const RESTRICTED_Z_RANGE = Vector2(47, 39)
func is_position_valid(base_position: Vector3) -> bool:
	if (base_position.x <= RESTRICTED_X_RANGE[0] && base_position.x >= RESTRICTED_X_RANGE[1]):
		if (base_position.z <= RESTRICTED_Z_RANGE[0] && base_position.z >= RESTRICTED_Z_RANGE[1]):
			return false  # Position is inside the restricted area
	return true  # Position is valid
func can_place_building() -> bool:
	var building_data = buildings[selectedBuildingIndex]
	if($"..".can_buy(building_data.resourceName,building_data.resourceCost,true) == false):
		return false
	if(ui_script.isInUI):
		return false
	
	var base_position = previewMesh.global_transform.origin
	print(base_position)
	if (is_position_valid(base_position) == false):
		return false
	var rotated_offsets = get_rotated_offsets(building_data.occupiedCells, buildRotation)

	for offset in rotated_offsets:
		var key = Vector2i(base_position.x + offset.x * GRID_SIZE, base_position.z + offset.y * GRID_SIZE)
		if key in building_map:
			return false

	return true

func place_building() -> void:
	
	
	var building_data = buildings[selectedBuildingIndex]
	$"..".consume_resouce(building_data.resourceName,building_data.resourceCost)
	if building_data.sceneToPlace and ResourceLoader.exists(building_data.sceneToPlace):
		var scene_resource = load(building_data.sceneToPlace)
		if scene_resource is PackedScene:
			var new_building = scene_resource.instantiate()
			if is_instance_valid(buildingParent):
				buildingParent.add_child(new_building)
				new_building.global_transform.origin = previewMesh.global_transform.origin
				new_building.rotation_degrees.y = previewMesh.rotation_degrees.y

				var base_position = previewMesh.global_transform.origin
				var rotated_offsets = get_rotated_offsets(building_data.occupiedCells, buildRotation)
				
				new_building.building_index = selectedBuildingIndex
				new_building.buildRotation = buildRotation
				new_building.origin_cord[0] = base_position.x
				new_building.origin_cord[1] = base_position.z
				new_building.couldRotate = buildings[selectedBuildingIndex].canRotate
				$"../../Control".playPlaceSound(false)
				if(selectedBuildingIndex == 1):
					$"..".max_units += 1
				if(selectedBuildingIndex == 2):
					$"..".max_units += 2
				$"..".update_ui()
				if(new_building.building_index == 0):
					add_crop(new_building)

				for offset in rotated_offsets:
					var key = Vector2i(base_position.x + offset.x * GRID_SIZE, base_position.z + offset.y * GRID_SIZE)
					building_map[key] = new_building
					new_building.tiles_used.append(key)
				$"../../NavigationRegion3D".bake_navigation_mesh(true)
			else:
				pass
		else:
			pass
	else:
		pass

func switch_building(index: int) -> void:
	selectedBuildingIndex = index
	var building_data = buildings[selectedBuildingIndex]
	
	
	var preview_path = building_data.previewMesh
	if has_node(preview_path):
		previewMesh = get_node(preview_path)
	else:
		print("Error: Preview mesh not found at path:", preview_path)
	
	sceneToPlace = building_data.sceneToPlace


func get_rotated_offsets(offsets: Array, rotation: int) -> Array:
	var rotated_offsets = []
	for offset in offsets:
		var new_offset = Vector2(offset.x, offset.y)
		if rotation == 90:
			new_offset = Vector2(-offset.y, offset.x)
		elif rotation == 180:
			new_offset = Vector2(-offset.x, -offset.y)
		elif rotation == 270:
			new_offset = Vector2(offset.y, -offset.x)
		rotated_offsets.append(new_offset)
	return rotated_offsets


func debug() -> void:
	var debug_parent = $"../../Buildings"  

	var debug_plane_scene = preload("res://Models/Farm/SM_PreviewCrop.tscn")  

	for key in building_map.keys():
		if debug_plane_scene is PackedScene:
			var debug_plane = debug_plane_scene.instantiate()
			debug_plane.global_transform.origin = Vector3(key.x * 1, 0.1, key.y * 1)
			debug_parent.add_child(debug_plane)
		else:
			print("Error: Debug plane scene is not a PackedScene!")
