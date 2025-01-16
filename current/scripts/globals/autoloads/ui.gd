extends Node

var menu_open: bool = false
var pause_menu: Resource = load("res://current/menus/escape_menu/escape_menu.tscn")
var cur_menu: Control
var lobbies: VBoxContainer
var chat_box: Control
var chat_log: Array = []
const DEFAULT_FONT_SIZE: float = 30.0
const DEFAULT_CHAT_FONT_SIZE: float = 20.0

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		chat_box.release_input_focus()
		if Saves.save_loaded:
			if not menu_open:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				var new_menu: Control = pause_menu.instantiate()
				get_tree().root.add_child(new_menu)
				cur_menu = new_menu
				menu_open = true
			else:
				close_menu()
	elif Input.is_action_just_pressed("send_message"):
		chat_box.release_focus()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif Input.is_action_just_pressed("chat"):
		chat_box.open_text_input()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func show_system_message(message: String) -> void:
	if chat_box != null:
		chat_box.show_system_message(message)
	else:
		while chat_box == null:
			await get_tree().process_frame
		chat_box.show_system_message(message)

func show_system_warning(message: String) -> void:
	if chat_box != null:
		chat_box.show_system_warning(message)
	else:
		while chat_box == null:
			await get_tree().process_frame
		chat_box.show_system_warning(message)

func sent_chat_message(message: String, private: bool, target: int) -> void:
	chat_box.sent_chat_message(message, private, target)

func open_menu(menu_path: String) -> void:
	var old_menu: Control = cur_menu
	var new_menu: Control = load(menu_path).instantiate()
	get_tree().root.add_child(new_menu)
	cur_menu = new_menu
	if old_menu != null:
		old_menu.queue_free()

func close_menu() -> void:
	if cur_menu:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_tree().root.remove_child(cur_menu)
		cur_menu.queue_free()
		cur_menu = null
		menu_open = false

func process_chat_message(message: Dictionary) -> void:
	chat_box.process_chat_message(message)
