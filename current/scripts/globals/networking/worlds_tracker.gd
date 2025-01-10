extends Node


var worlds: Dictionary = {}
var current_world: String = "default"

func add_to_world(world: String, pid: int) -> void:
	if !worlds.has(world):
		worlds[world] = []
	for world_array: String in worlds:
		worlds[world_array].erase(pid)
	worlds[world].append(pid)

func remove_from_worlds(pid: int) -> void:
	for world: String in worlds:
		worlds[world].erase(pid)

func has(world: String, pid: int) -> bool:
	if !worlds.has(world):
		return false
	else:
		return worlds[world].has(pid)

func update_world(new_world: String) -> void:
	current_world = new_world
	send_world(0)

func send_world(pid: int) -> void:
	SteamP2P.sendMessageToUser(pid, {"type": "world_info", "world": current_world})

func clear_worlds() -> void:
	worlds = {}
