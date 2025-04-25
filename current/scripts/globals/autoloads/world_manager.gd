extends Node


var worlds: Dictionary = {}
var current_world_name: String = "default"
var current_world: Variant = null
var current_instance_id: int = -1
var middleground: Node2D
var first_world_started: bool = false
var door_cooldown: bool = false
var doors: Dictionary[String, Variant] = {}

func add_to_world(pid: int, world: String = current_world_name, instance_id: int = -1) -> void:
	if !worlds.has(world):
		worlds[world] = {}
		worlds[world][instance_id] = {}
	else:
		if !worlds[world].has(instance_id):
			worlds[world][instance_id] = {}
	for world_array: String in worlds:
		for world_instance: int in worlds[world_array]:
			worlds[world_array][world_instance].erase(pid)
	worlds[world][instance_id][pid] = SteamLobbies.lobby_members[pid]["steam_name"]
	if world != current_world_name or instance_id != current_instance_id:
		SteamP2P.remove_kitty(pid)

func set_door(door: Variant, door_name: String = "Door") -> void:
	doors[door_name] = door

func remove_from_worlds(pid: int) -> void:
	for world: String in worlds:
		for world_instance: int in worlds[world]:
			worlds[world][world_instance].erase(pid)

func has(pid: int, world: String = current_world_name, instance_id: int = current_instance_id) -> bool:
	if !worlds.has(world):
		return false
	elif !worlds[world].has(instance_id):
		return false
	else:
		return worlds[world][instance_id].has(pid)

func get_same_world() -> Dictionary:
	if !worlds.has(current_world_name):
		return {}
	elif !worlds[current_world_name].has(current_instance_id):
		return {}
	else:
		return worlds[current_world_name][current_instance_id]

func change_world(world_path: String, instance_id: int = -1) -> void:
	if MinigameManager.current_minigame != null:
		MinigameManager.minigame_display.remove_child(MinigameManager.current_minigame)
	doors.clear()
	Ui.close_menu()
	var world_packed: PackedScene = load(world_path)
	if world_packed != null:
		StabilityMitigator.reset_movement_ids()
		current_world_name = world_packed.get_state().get_node_name(0)
		current_instance_id = instance_id
		get_tree().change_scene_to_packed(world_packed)
		while !get_tree().current_scene:
			await get_tree().process_frame
		initialize_pos()
		middleground = get_node("/root/" + current_world_name + "/Middleground")
		Saves.set_value("settings", "world_path", world_path)
		send_world()
		Ui.show_system_message("Now entering " + current_world_name, Color.CYAN, false, "")
		await get_tree().process_frame
		if Saves.get_or_return("settings", "first_load", true):
			Ui.open_menu("res://current/menus/First_load_menu/first_load.tscn")
			Saves.set_value("settings", "first_load", false)
	else:
		Ui.show_system_debug("The world that you tried to load was not found")

func door_teleport(body: Variant, world_path: String, door: String = "", door_offset: Vector2 = Vector2(0,0), instance_id: int = -1) -> void:
	if body == GlobalVars.mieu:
		WorldManager.change_world_door.call_deferred(world_path, door, door_offset, body.get_frame(), instance_id)

func change_world_door(world_path: String, door: String = "", door_offset: Vector2 = Vector2(0,0), frame: int = 0, instance_id: int = -1) -> void:
	if !door_cooldown:
		StabilityMitigator.reset_movement_ids()
		if MinigameManager.current_minigame != null:
			MinigameManager.minigame_display.remove_child(MinigameManager.current_minigame)
		door_cooldown = true
		doors.clear()
		Ui.close_menu()
		var world_packed: PackedScene = load("res://current/scenes/worlds/" + world_path)
		if world_packed != null:
			current_world_name = world_packed.get_state().get_node_name(0)
			current_instance_id = instance_id
			get_tree().change_scene_to_packed(world_packed)
			while !get_tree().current_scene:
				await get_tree().process_frame
			get_tree().current_scene.modulate = Color(1, 1, 1, .50)
			get_tree().create_tween().tween_property(get_tree().current_scene, "modulate", Color(1, 1, 1, 1), 1.5).set_ease(Tween.EASE_OUT)
			initialize_pos(door, door_offset, frame)
			middleground = get_node("/root/" + current_world_name + "/Middleground")
			Saves.set_value("settings", "world_path", world_path)
			send_world()
			Ui.show_system_message("Now entering " + current_world_name, Color.CYAN, false, "")
			await get_tree().create_timer(.25).timeout
			door_cooldown = false
		else:
			Ui.show_system_debug("The world that you tried to load was not found")

func initialize_pos(door: String = "", door_offset: Vector2 = Vector2(0,0), frame: int = 0) -> void:
	while GlobalVars.mieu == null:
		await get_tree().process_frame
	if door.is_empty():
		if first_world_started == false and is_instance_valid(GlobalVars.mieu):
			GlobalVars.mieu.global_position = Vector2(Saves.get_or_add("Player","pos_x", GlobalVars.mieu.global_position.x), Saves.get_or_add("Player","pos_y", GlobalVars.mieu.global_position.y))
			first_world_started = true
	else:
		if doors.has(door) and is_instance_valid(doors[door]):
			GlobalVars.mieu.global_position = doors[door].get_child(0).global_position + door_offset
			GlobalVars.mieu.set_frame(frame)
	GlobalVars.mieu.show()

func update_world(world: Variant) -> void:
	current_world = world
	if world.instanced and current_instance_id == -1:
		current_instance_id = SteamWorks.steam_id
		send_world()

func send_world(pid: int = 0) -> void:
	SteamP2P.send_message_to_user({"type": "world_info", "world_name": current_world_name, "instance_id": current_instance_id}, pid)

func clear_worlds() -> void:
	worlds.clear()
