extends Node


var worlds: Dictionary = {}
var current_world_name: String = "default"
var current_world: Variant = null
var current_instance_id: int = -1
var middleground: Node2D
var dimensions: int = 0
var first_world_started: bool = false

func add_to_world(pid: int, world: String = current_world, instance_id: int = -1) -> void:
	if !worlds.has(world):
		worlds[world] = {}
		worlds[world][instance_id] = {}
	else:
		if !worlds[world].has(instance_id):
			worlds[world][instance_id] = {}
	for world_array: String in worlds:
		for world_instance: int in worlds[world_array]:
			worlds[world_array][world_instance].erase(pid)
	worlds[world][instance_id].append(pid)
	if world != current_world_name or instance_id != current_instance_id:
		SteamP2P.remove_kitty(pid)

func remove_from_worlds(pid: int) -> void:
	for world: String in worlds:
		for world_instance: int in worlds[world]:
			worlds[world][world_instance].erase(pid)

func has(pid: int, world: String = current_world, instance_id: int = -1) -> bool:
	if !worlds.has(world):
		return false
	elif !worlds[world].has(instance_id):
		return false
	else:
		return worlds[world][instance_id].has(pid)

func change_world(world_path: String, instance_id: int = -1) -> void:
	Ui.close_menu()
	var world_packed: PackedScene = load(world_path)
	if world_packed != null:
		current_world_name = world_packed.get_state().get_node_name(0)
		current_instance_id = instance_id
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
			middleground = get_node("/root/" + current_world_name + "/Middleground")
		Saves.set_value("settings", "world_path", world_path)
		initialize_pos()
		send_world()
		Ui.show_system_message("Now entering " + current_world_name, Color.CYAN, true, "")
	else:
		Ui.show_system_debug("The world that you tried to load was not found")

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

func update_world(world: Variant) -> void:
	current_world = world
	if world.instanced and current_instance_id == -1:
		current_instance_id = SteamWorks.steam_id
		send_world()

func send_world(pid: int = 0) -> void:
	SteamP2P.send_message_to_user({"type": "world_info", "world": current_world_name, "instance": current_instance_id}, pid)

func clear_worlds() -> void:
	worlds.clear()
