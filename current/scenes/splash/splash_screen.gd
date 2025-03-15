extends Node2D


var instanced: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WorldManager.update_world(self)
