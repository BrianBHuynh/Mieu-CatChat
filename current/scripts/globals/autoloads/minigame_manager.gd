extends Node


var current_minigame: Variant = null
var minigame_display: Window = null
var current_minigame_name: String = ""
var current_minigame_instance_id: int = -1
var minigame_stats: Dictionary = {}
var minigames: Dictionary = {}

func is_minigame_open() -> bool:
	return minigame_display.visible

func minigame_close() -> void:
	minigame_display.hide()
	minigame_display.pause()

func minigame_open(minigame_path: String = "", minigame_instance_id: int = -1) -> void:
	if minigame_path.is_empty():
		minigame_display.show()
	else:
		var minigame_instance: Variant = load(minigame_path).instantiate()
		if minigame_instance.name != current_minigame_name:
			current_minigame = minigame_instance
			current_minigame_name = minigame_instance.name
			current_minigame_instance_id = minigame_instance_id
			for minigame_node: Node2D in minigame_display.get_children():
				minigame_node.queue_free()
			minigame_display.add_child(minigame_instance)
		elif minigame_display.get_child_count() == 0:
			minigame_display.add_child(current_minigame)
		minigame_display.show()

func get_minigame() -> Variant:
	return current_minigame

func close_minigame() -> void:
	minigame_display.hide()

func accept_minigame_data(message: Dictionary) -> void:
	if current_minigame != null:
		current_minigame.accept_minigame_data(message)

func send_minigame_info(pid: int = 0) -> void:
	SteamP2P.send_message_to_user({"type": "minigame_info", "minigame_name": current_minigame, "minigame_instance_id": current_minigame_instance_id}, pid)

func add_to_minigame(pid: int, minigame: String = current_minigame_name, minigame_instance_id: int = -1) -> void:
	if !minigames.has(minigame):
		minigames[minigame] = {}
		minigames[minigame][minigame_instance_id] = {}
	elif !minigames[minigame].has(minigame_instance_id):
		minigames[minigame][minigame_instance_id] = {}
	
	for minigame_array: String in minigames:
		for minigame_instance: int in minigames[minigame_array]:
			minigames[minigame_array][minigame_instance].erase(pid)
	minigames[minigame][minigame_instance_id][pid] = SteamLobbies.lobby_members[pid]["steam_name"]

func has(pid: int, minigame: String = current_minigame_name, minigame_instance_id: int = -1) -> bool:
	if not (minigames.has(minigame) or minigames[minigame].has(minigame_instance_id)):
		return false
	else:
		return minigames[minigame][minigame_instance_id].has(pid)

func get_same_minigame() -> Dictionary:
	if not (minigames.has(current_minigame_name) or minigames[current_minigame_name].has(current_minigame_instance_id)):
		return {}
	else:
		return minigames[current_minigame_name][current_minigame_instance_id]
