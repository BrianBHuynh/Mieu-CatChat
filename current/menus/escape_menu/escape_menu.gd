extends Control


func _on_settings_btn_pressed() -> void:
	Ui.open_menu("res://current/menus/settings_menu/settings_menu.tscn")


func _on_multiplayer_pressed() -> void:
	if Saves.save_loaded:
		Ui.open_menu("res://current/menus/multiplayer_menus/lobbies_menu/lobbies_menu.tscn")

func _on_save_pressed() -> void:
	if Saves.save_loaded:
		Saves.save_game()


func _on_credit_btn_pressed() -> void:
	Ui.open_menu("res://current/menus/credits_and_licenses_menu/credits_and_licenses.tscn")


func _on_reset_pos_pressed() -> void:
	if GlobalVars.reset_position != null:
		GlobalVars.mieu.global_position = GlobalVars.reset_position


func _on_exit_btn_pressed() -> void:
	get_tree().quit()
