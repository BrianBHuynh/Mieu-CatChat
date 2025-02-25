extends Control

func _on_check_button_toggled(toggled_on: bool) -> void:
	get_viewport().get_camera_3d().mode(toggled_on)


func _on_debug_2d_pressed() -> void:
	WorldsTracker.update_world("res://current/scenes/templates/main_scenes/2D_scene_template/2D_scene_template.tscn")


func _on_debug_3d_pressed() -> void:
	WorldsTracker.update_world("res://current/scenes/templates/main_scenes/3D_scene_template/3D_scene_template.tscn")


func _on_debug_text_pressed() -> void:
	if Saves.get_or_return("settings", "show_debug", false):
		Saves.set_value("settings", "show_debug", false)
	else:
		Saves.set_value("settings", "show_debug", true)


func _on_minigame_pressed() -> void:
	MinigameManager.minigame_open("res://current/scenes/templates/main_scenes/2D_minigame_template/2D_minigame_template.tscn")
