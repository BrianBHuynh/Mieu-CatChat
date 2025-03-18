extends Control


func _on_accessibility_pressed() -> void:
	Ui.open_menu("res://current/menus/accessibility_menu/accessibility_menu.tscn")

func _on_video_pressed() -> void:
	Ui.open_menu("res://current/menus/video_menu/video_menu.tscn")

func _on_debug_pressed() -> void:
	Ui.open_menu("res://current/menus/debug_menu/debug_menu.tscn")
