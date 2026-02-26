extends Node2D


var instanced: bool = false


func _ready() -> void:
	WorldManager.update_world(self)
