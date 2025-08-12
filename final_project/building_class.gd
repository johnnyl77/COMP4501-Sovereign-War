class_name BuildingClass

var previewMesh
var sceneToPlace
var occupiedCells
var canRotate
var resourceName
var resourceCost

func _init(preview: NodePath, scene: String, occupied: Array, x : bool, rname : String, rCost : int) -> void:
	previewMesh = preview
	sceneToPlace = scene
	occupiedCells = occupied
	canRotate = x
	resourceName = rname
	resourceCost = rCost
