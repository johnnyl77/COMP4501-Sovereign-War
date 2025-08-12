extends Node3D

func _ready() -> void:
	knight = load("res://unit.tscn")
	mage = load("res://Models/Mage/mage_unit.tscn")
	enemey = load("res://enemy_unit.tscn")
	miner = load("res://miner_unit.tscn")
	farmer = load("res://farmer_unit.tscn")
	lumber = load("res://lumber_unit.tscn")
	mace = load("res://mace_unit.tscn")


var knight  
var mage
var miner
var farmer 
var lumber
var enemey
var mace


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("five_key"):
		spawn_unit(3,1)
	pass
		
	

func spawn_unit(id: int, is_friendly: int):
	var scene
	var unit_add = 1
	if(id == 5):
		scene = mage
		
	if(id == 3):
		scene = knight
	if (id == 4):
		scene = mace
	if(id == 2):
		scene = miner
	if(id == 0):
		scene = farmer
	if(id == 1):
		scene = lumber
	if(id == 6):
		scene = enemey
		is_friendly = 1
		id = 3
		unit_add = 0
	
	if(is_friendly == 0):
		$"..".units += 1
	$"..".update_ui()
	
	if scene:
		var unit_instance = scene.instantiate()  
		var parent_node = get_node("../../Units")
	
		if parent_node:
			parent_node.add_child(unit_instance) 

			unit_instance.init_vars(id,is_friendly)
			
	
			if(is_friendly == 0):
				unit_instance.position = Vector3(0, 0,43)  
			if(is_friendly == 1):
				unit_instance.position = Vector3(0, 0,-43)
		
			return unit_instance 
	else:
		pass
	
	return null
