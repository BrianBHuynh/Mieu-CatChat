extends Control

func _on_save_pressed() -> void:
	Saves.add_data("Player", "pos", GlobalVars.mieu.position)
	Saves.save_game()

func _on_accessibility_pressed() -> void:
	var new_menu: Control = load("res://current/menus/accessibility_menu/accessibility_menu.tscn").instantiate()
	get_tree().root.add_child(new_menu)
	Controls.cur_menu = new_menu
	self.queue_free()

func _on_video_pressed() -> void:
	var new_menu: Control = load("res://current/menus/video_menu/video_menu.tscn").instantiate()
	get_tree().root.add_child(new_menu)
	Controls.cur_menu = new_menu
	self.queue_free()
