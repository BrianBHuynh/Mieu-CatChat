extends Node


var worlds: Dictionary = {}
var current_world: String = "default"
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
	Saves.set_value("settings", "world_path", world_path)
	initialize_pos()
	send_world(0)
	Ui.show_system_message("Current world: " + current_world)
	Ui.show_system_message("2D or 3D: " + str(dimensions))

func initialize_pos() -> void:
	if first_world_started == false and GlobalVars.mieu:
		await get_tree().process_frame
		match dimensions: 
			3:
				GlobalVars.mieu.position = Vector3(Saves.get_or_add("Player","pos_x", GlobalVars.mieu.position.x), Saves.get_or_add("Player","pos_y", GlobalVars.mieu.position.y), Saves.get_or_add("Player","pos_z", GlobalVars.mieu.position.z))
				GlobalVars.mieu.rotation = Vector3(Saves.get_or_add("Player", "rot_x", GlobalVars.mieu.rotation.x), Saves.get_or_add("Player", "rot_y", GlobalVars.mieu.rotation.y), Saves.get_or_add("Player", "rot_z", GlobalVars.mieu.rotation.z))
			2:
				GlobalVars.mieu.position = Vector2(Saves.get_or_add("Player","pos_x", GlobalVars.mieu.position.x), Saves.get_or_add("Player","pos_y", GlobalVars.mieu.position.y))
			_:
				pass
		first_world_started = true

func send_world(pid: int) -> void:
	SteamP2P.sendMessageToUser(pid, {"type": "world_info", "world": current_world})

func clear_worlds() -> void:
	worlds = {}
