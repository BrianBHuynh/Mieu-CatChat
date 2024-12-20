extends Control

func _on_save_pressed() -> void:
	Saves.set_value("Player", "pos", GlobalVars.mieu.position)
	Saves.save_game()

func _on_accessibility_pressed() -> void:
	Controls.open_menu("res://current/menus/accessibility_menu/accessibility_menu.tscn")

func _on_video_pressed() -> void:
	Controls.open_menu("res://current/menus/video_menu/video_menu.tscn")


func _on_debug_pressed() -> void:
	Controls.open_menu("res://current/menus/debug_menu/debug_menu.tscn")
	print("Opening debug menu")

func _on_multiplayer_pressed() -> void:
	if Steam.isSteamRunning():
		Controls.open_menu("res://current/menus/chat_menus/multiplayer_menu/multiplayer_menu.tscn")
