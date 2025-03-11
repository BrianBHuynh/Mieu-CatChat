extends Control

func _on_save_pressed() -> void:
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
	if GlobalVars.reset_position != null:
		GlobalVars.mieu.global_position = GlobalVars.reset_position

func _on_input_btn_pressed() -> void:
	Ui.open_menu("res://current/menus/input_menu/input_menu.tscn")

func _on_credit_btn_pressed() -> void:
	Ui.open_menu("res://current/menus/credits_and_licenses_menu/credits_and_licenses.tscn")
