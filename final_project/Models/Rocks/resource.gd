extends Area3D


func _ready() -> void:
	pass 


func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("collided_with_tree"):
		body.collided_with_tree()  
