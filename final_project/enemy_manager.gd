extends Node3D

var health = 100

var miners = 0
var lumbers = 0
var knights = 0
var time_elapsed = 0
func _ready() -> void:
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(health <= 0):
		$"../../Control".end_game(true)
	time_elapsed += delta
	if time_elapsed >= 20.0:
		time_elapsed = 0.0
		spawnunit()

func spawnunit() -> void:
	var random_number = randi() % 4 + 1
	if(random_number == 1 && lumbers > 10):
		random_number = 3
	if(random_number == 2 && miners > 10):
		random_number = 3
	if(random_number == 3 || random_number == 4 && knights > 50):
		return
	if(random_number > 2):
		random_number = 6
	$"../UnitManager".spawn_unit(random_number,1)
