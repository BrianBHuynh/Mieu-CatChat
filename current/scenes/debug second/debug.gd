extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	WorldsTracker.update_world("debug_2")
	Saves.set_value("settings", "world_path", "res://current/scenes/debug second/debug.tscn")
	GlobalVars.initialize_pos()
