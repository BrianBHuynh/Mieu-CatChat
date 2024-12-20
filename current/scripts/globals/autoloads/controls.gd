extends Node

var menu_open: bool = false
var menu: Resource = load("res://current/menus/escape_menu/escape_menu.tscn")
var cur_menu: Control
var lobbies: VBoxContainer
var chat_box: Control

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		chat_box.release_input_focus()
		if not menu_open:
			var new_menu: Control = menu.instantiate()
			get_tree().root.add_child(new_menu)
			cur_menu = new_menu
			menu_open = true
		else:
			get_tree().root.remove_child(cur_menu)
			cur_menu.queue_free()
			cur_menu = null
			menu_open = false
	elif Input.is_action_just_pressed("send_message"):
		chat_box.release_focus()
	elif Input.is_action_just_pressed("chat"):
		chat_box.open_text_input()

func show_system_message(message: String) -> void:
	chat_box.show_system_message(message)

func sent_chat_message(message: String, private: bool, target: int) -> void:
	chat_box.sent_chat_message(message, private, target)

func open_menu(menu_path: String) -> void:
	var old_menu: Control = cur_menu
	var new_menu: Control = load(menu_path).instantiate()
	get_tree().root.add_child(new_menu)
	cur_menu = new_menu
	if old_menu != null:
		old_menu.queue_free()
