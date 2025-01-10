extends Node


var worlds: Dictionary = {}
var current_world: String = "default"

func add_to_world(world: String, pid: int) -> void:
	if !worlds.has(world):
		worlds[world] = []
	for world_array in worlds:
		world_array.erase(pid)
	worlds[world].append(pid)

func has(world: String, pid: int) -> bool:
	if !worlds.has(world):
		return false
	else:
		return worlds[world].has(pid)
