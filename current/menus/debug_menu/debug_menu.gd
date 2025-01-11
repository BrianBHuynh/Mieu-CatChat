extends Control

func _on_check_button_toggled(toggled_on: bool) -> void:
	get_viewport().get_camera_3d().mode(toggled_on)


func _on_debug_scene_change_pressed() -> void:
	get_tree().change_scene_to_packed(load("res://current/scenes/debug second/debug.tscn"))
