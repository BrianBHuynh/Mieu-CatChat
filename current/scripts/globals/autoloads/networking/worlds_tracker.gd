extends Node


var worlds: Dictionary = {}
var current_world: String = "default"
var middleground: Node2D
var dimensions: int = 0
var first_world_started: bool = false

func add_to_world(world: String, pid: int) -> void:
	if !worlds.has(world):
		worlds[world] = []
	for world_array: String in worlds:
		worlds[world_array].erase(pid)
	worlds[world].append(pid)
	if world != current_world:
		SteamP2P.remove_kitty(pid)

func remove_from_worlds(pid: int) -> void:
	for world: String in worlds:
		worlds[world].erase(pid)

func has(world: String, pid: int) -> bool:
	if !worlds.has(world):
		return false
	else:
		return worlds[world].has(pid)

func update_world(world_path: String) -> void:
	Ui.close_menu()
	var world_packed: PackedScene = load(world_path)
	if world_packed != null:
		current_world = world_packed.get_state().get_node_name(0)
		match world_packed.get_state().get_node_type(0):
			"Node2D":
				dimensions = 2
			"Node3D":
				dimensions = 3
			_:
				Ui.show_system_warning("Invalid world type, world type is: " + world_packed.get_state().get_node_type(0))
		get_tree().change_scene_to_packed(world_packed)
		while !get_tree().current_scene:
			await get_tree().process_frame
		if dimensions == 2:
			middleground = get_node("/root/" + current_world + "/Middleground")
		Saves.set_value("settings", "world_path", world_path)
		initialize_pos()
		send_world()
		Ui.show_system_message("Now entering " + current_world, Color.CYAN, true, "")

func initialize_pos() -> void:
	if first_world_started == false and is_instance_valid(GlobalVars.mieu):
		match dimensions: 
			3:
				GlobalVars.mieu.global_position = Vector3(Saves.get_or_add("Player","pos_x", GlobalVars.mieu.global_position.x), Saves.get_or_add("Player","pos_y", GlobalVars.mieu.global_position.y), Saves.get_or_add("Player","pos_z", GlobalVars.mieu.global_position.z))
				GlobalVars.mieu.rotation = Vector3(Saves.get_or_add("Player", "rot_x", GlobalVars.mieu.rotation.x), Saves.get_or_add("Player", "rot_y", GlobalVars.mieu.rotation.y), Saves.get_or_add("Player", "rot_z", GlobalVars.mieu.rotation.z))
			2:
				GlobalVars.mieu.global_position = Vector2(Saves.get_or_add("Player","pos_x", GlobalVars.mieu.global_position.x), Saves.get_or_add("Player","pos_y", GlobalVars.mieu.global_position.y))
			_:
				pass
		first_world_started = true

func send_world(pid: int = 0) -> void:
	SteamP2P.sendMessageToUser({"type": "world_info", "world": current_world}, pid)

func clear_worlds() -> void:
	worlds.clear()
