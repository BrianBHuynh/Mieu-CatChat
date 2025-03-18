extends Control


func _on_text_btn_pressed() -> void:
	Ui.open_menu("res://current/menus/text_menu/text_menu.tscn")

func _on_video_pressed() -> void:
	Ui.open_menu("res://current/menus/video_menu/video_menu.tscn")

func _on_debug_pressed() -> void:
	Ui.open_menu("res://current/menus/debug_menu/debug_menu.tscn")
