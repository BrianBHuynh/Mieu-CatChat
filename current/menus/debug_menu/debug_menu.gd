extends Control


func _on_minigame_pressed() -> void:
	MinigameManager.minigame_open("res://current/scenes/minigame_template/minigame_template.tscn")

func _on_world_manager_pressed() -> void:
	Ui.show_system_debug(str(WorldManager.worlds) + str(WorldManager.current_instance_id))

func _on_debug_messages_pressed() -> void:
	if Saves.get_or_return("settings", "show_debug", false):
		Saves.set_value("settings", "show_debug", false)
	else:
		Saves.set_value("settings", "show_debug", true)
