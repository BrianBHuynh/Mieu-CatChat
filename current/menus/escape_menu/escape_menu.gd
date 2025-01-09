extends Control

func _on_save_pressed() -> void:
	Saves.set_value("Player", "pos_x", GlobalVars.mieu.position.x)
	Saves.set_value("Player", "pos_y", GlobalVars.mieu.position.y)
	Saves.set_value("Player", "pos_z", GlobalVars.mieu.position.z)
	Saves.save_game()

func _on_accessibility_pressed() -> void:
	Ui.open_menu("res://current/menus/accessibility_menu/accessibility_menu.tscn")

func _on_video_pressed() -> void:
	Ui.open_menu("res://current/menus/video_menu/video_menu.tscn")

func _on_debug_pressed() -> void:
	Ui.open_menu("res://current/menus/debug_menu/debug_menu.tscn")

func _on_multiplayer_pressed() -> void:
	if Steam.isSteamRunning():
		Ui.open_menu("res://current/menus/multiplayer_menus/lobbies_menu/lobbies_menu.tscn")
	else:
		Ui.show_system_message("Steam is not currently open!")

func _on_reset_pos_pressed() -> void:
	GlobalVars.mieu.global_position = Vector3(0, 1, 0)
