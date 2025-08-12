extends Node

var tiles_used = []
var building_index = 0
var buildRotation = 0
var origin_cord = [0,0]
var couldRotate = true
var resource_count = 0




func _ready() -> void:
	pass 



var seeded: bool = false
var grown: float = 0.0  #
var growth_time: float = 20.0  
var elapsed_time: float = 0.0

@onready var crop1: Node3D = $SM_CropField
@onready var crop2: Node3D = $SM_CropField2

func _process(delta: float) -> void:
	if seeded and grown < 1.0:  
		elapsed_time += delta
		grown = elapsed_time / growth_time  


		crop1.scale.z = lerp(1.0, 200.0, grown)
		crop2.scale.z = lerp(1.0, 200.0, grown)

		# Ensure growth doesn't exceed 1.0
		grown = min(grown, 1.0)

		if grown >= 1.0:
			$"../../Player/BuildingManager".add_crop(self)
			resource_count = 10
	

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("collided_with_farm"):
		if body.unit_type == 0 and not seeded: 
			seeded = true
			grown = 0.0
			elapsed_time = 0.0 
			body.collided_with_farm(self)
	
		if grown == 1 and body.unit_type == 0:
			body.collided_with_farm(self)
			reset_crops()
	
	# Add the turret code here
	# if body type == enemy and it's not currently focusing an enemy or shooting at one
		# then shoot at that new enemy
	# 

func reset_crops() -> void:
	crop1.scale.z = 1.0
	crop2.scale.z = 1.0
	seeded = true
	grown = 0.0 
	elapsed_time = 0.0 
	resource_count = 0
