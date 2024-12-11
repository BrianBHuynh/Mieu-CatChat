extends Control

func _on_save_pressed() -> void:
	Saves.set_value("Player", "pos", GlobalVars.mieu.position)
	Multithreading.add_task(Callable(Saves,"save_game"))

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


func _on_debug_pressed() -> void:
	var new_menu: Control = load("res://current/menus/debug_menu/debug_menu.tscn").instantiate()
	get_tree().root.add_child(new_menu)
	Controls.cur_menu = new_menu
	self.queue_free()


func _on_multiplayer_pressed() -> void:
	var new_menu: Control = load("res://current/menus/chat_menus/multiplayer_menu/multiplayer_menu.tscn").instantiate()
	get_tree().root.add_child(new_menu)
	Controls.cur_menu = new_menu
	self.queue_free()
