extends Control


func _on_check_button_toggled(toggled_on: bool) -> void:
	get_viewport().get_camera_3d().mode(toggled_on)
