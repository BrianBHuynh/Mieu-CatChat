extends Node


var minigame: Variant = null
var minigame_display: Window = null
var minigame_name: String = ""
var minigame_instance_id: int = -1
var minigame_stats: Dictionary = {}
var lost_focus_timer: int = -1

func _physics_process(_delta: float) -> void:
	if minigame_display.visible and !minigame_display.has_focus():
		lost_focus_timer = lost_focus_timer + 1
		if lost_focus_timer > 10:
			close_minigame()
	else:
		lost_focus_timer = -1

func is_minigame_open() -> bool:
	return minigame_display.visible

func minigame_close() -> void:
	minigame_display.hide()

func minigame_open(minigame_path: String = "") -> void:
	if minigame_path.is_empty():
		minigame_display.show()
	else:
		var minigame_instance: Variant = load(minigame_path).instantiate()
		if minigame_instance.name != minigame_name:
			minigame = minigame_instance
			minigame_name = minigame_instance.name
			for minigame_node: Node2D in minigame_display.get_children():
				minigame_node.queue_free()
			minigame_display.add_child(minigame_instance)
		minigame_display.show()

func minigame_dimensions() -> int:
	var dimensions: int
	match minigame.get_class:
		"Node2D":
			dimensions = 2
		"Node3D":
			dimensions = 3
		_:
			dimensions = -1
			Ui.show_system_warning("No minigame open")
	return dimensions

func get_minigame() -> Variant:
	if is_instance_valid(minigame):
		return minigame
	else:
		return null

func close_minigame() -> void:
	minigame_display.hide()

func accept_minigame_data(message: Dictionary) -> void:
	minigame.accept_minigame_data(message)

func send_minigame_info(pid: int = 0) -> void:
	SteamP2P.send_message_to_user({"type": "minigame_info", "minigame_name": minigame_name, "minigame_instance_id": minigame_instance_id}, pid)
