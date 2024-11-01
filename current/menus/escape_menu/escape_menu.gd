extends Control

func _on_debug_pressed() -> void:
	var new_menu: Control = load("res://current/menus/accessibility_menu/accessibility_menu.tscn").instantiate()
	get_tree().root.add_child(new_menu)
	Controls.cur_menu = new_menu
	self.queue_free()
