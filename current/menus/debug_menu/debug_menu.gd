extends Control

func _on_check_button_toggled(toggled_on: bool) -> void:
	get_viewport().get_camera_3d().mode(toggled_on)


func _on_debug_2d_pressed() -> void:
	WorldsTracker.update_world("res://current/scenes/2D/debug/2D_test_1/2D_test_1.tscn")


func _on_debug_3d_pressed() -> void:
	WorldsTracker.update_world("res://current/scenes/3D/debug/3D_test_1/3D_test_1.tscn")
