extends Node


var pause_menu: String = "res://current/menus/escape_menu/escape_menu.tscn"
var cur_menu: Control
var lobbies: VBoxContainer
var chat_box: Control
var chat_log: Array = []
const DEFAULT_FONT_SIZE: float = 30.0
const DEFAULT_CHAT_FONT_SIZE: float = 20.0

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if chat_box != null:
			chat_box.release_input_focus()
		if Saves.save_loaded:
			if not is_menu_open():
				set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				open_menu(pause_menu)
			else:
				close_menu()
	elif Input.is_action_just_pressed("send_message"):
		chat_box.release_focus()
		if WorldManager.dimensions == 3:
			set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.is_action_just_pressed("chat") and !is_menu_open():
		chat_box.open_text_input()
		set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func is_menu_open() -> bool:
	return is_instance_valid(cur_menu)

func show_system_message(content: String, color: Color = Color.DARK_BLUE, save: bool = false, prefix: String = "SYSTEM") -> void:
	while chat_box == null or !is_instance_valid(chat_box):
		await get_tree().process_frame
	chat_box.show_system_message(content, color, save, prefix)

func show_system_warning(message: String, color: Color = Color.DARK_BLUE) -> void:
	while chat_box == null or !is_instance_valid(chat_box):
		await get_tree().process_frame
	chat_box.show_system_warning(message, color)

func show_system_debug(message: String, color: Color = Color.BLACK) -> void:
	while chat_box == null or !is_instance_valid(chat_box):
		await get_tree().process_frame
	chat_box.show_system_debug(message, color)

func show_chat_message(message: Dictionary) -> void:
	while chat_box == null or !is_instance_valid(chat_box):
		await get_tree().process_frame
	chat_box.show_chat_message(message)

func sent_chat_message(message: String, target: int = 0, private: bool = false) -> void:
	while chat_box == null or !is_instance_valid(chat_box):
		await get_tree().process_frame
	chat_box.sent_chat_message(message, target, private)

func open_menu(menu_path: String) -> void:
	var old_menu: Control = cur_menu
	var new_menu: Control = load(menu_path).instantiate()
	get_tree().root.add_child(new_menu)
	cur_menu = new_menu
	if old_menu != null and is_instance_valid(old_menu):
		old_menu.queue_free()

func close_menu() -> void:
	if cur_menu:
		if WorldManager.dimensions == 3:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_tree().root.remove_child(cur_menu)
		cur_menu.queue_free()
		cur_menu = null

func set_mouse_mode(mode: int) -> void:
	if 3 >= mode and mode >= 0:
		Input.mouse_mode = mode as Input.MouseMode
