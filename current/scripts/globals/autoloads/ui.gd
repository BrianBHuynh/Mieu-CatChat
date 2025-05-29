extends Node


var pause_menu: String = "res://current/menus/escape_menu/escape_menu.tscn"
var canvas_layer: CanvasLayer
var cur_menu: Control
var lobbies: VBoxContainer
var chat_box: Control
var chat_log: Array = []
var chat_archive: String = ""
var max_log_size: int = 100
const DEFAULT_FONT_SIZE: float = 30.0
const DEFAULT_CHAT_FONT_SIZE: float = 25.0


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
	elif Input.is_action_just_pressed("chat") and !is_menu_open() and chat_box != null:
		chat_box.open_text_input()
	elif Input.is_action_just_pressed("player_list"):
		open_player_list()


func is_menu_open() -> bool:
	return is_instance_valid(cur_menu)


func show_system_message(content: String, color: Color = Color.DEEP_SKY_BLUE, save: bool = false, prefix: String = "SYSTEM") -> void:
	while chat_box == null or !is_instance_valid(chat_box):
		await get_tree().process_frame
	
	chat_box.show_system_message(content, color, save, prefix)


func show_system_warning(message: String, color: Color = Color.DARK_BLUE) -> void:
	while chat_box == null or !is_instance_valid(chat_box):
		await get_tree().process_frame
	
	chat_box.show_system_warning(message, color)


func show_system_debug(message: String, color: Color = Color.DARK_SLATE_BLUE) -> void:
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
	while canvas_layer == null or !is_instance_valid(canvas_layer):
		await get_tree().process_frame
	
	canvas_layer.add_child(new_menu)
	cur_menu = new_menu
	if old_menu != null and is_instance_valid(old_menu):
		old_menu.queue_free()


func open_player_list() -> void:
	var tab_menu: Control = load("res://current/menus/tab_list/tab_list.tscn").instantiate()
	while canvas_layer == null or !is_instance_valid(canvas_layer):
		await get_tree().process_frame
	
	canvas_layer.add_child(tab_menu)


func close_menu() -> void:
	if cur_menu and canvas_layer != null and is_instance_valid(canvas_layer):
		canvas_layer.remove_child(cur_menu)
		if cur_menu.has_method("close"):
			cur_menu.close()
		cur_menu.queue_free()
		cur_menu = null


func set_mouse_mode(mode: int) -> void:
	if 3 >= mode and mode >= 0:
		Input.mouse_mode = mode as Input.MouseMode


func chat_log_add(chat_message: Dictionary) -> void:
	var last_message: Dictionary
	if chat_log.size() > 0:
		last_message = chat_log.pop_back()
		if (
		last_message["type"] == "chat_message" 
		and last_message["sender"] == chat_message["sender"] 
		and last_message["target"] == chat_message["target"]
		):
			last_message["content"] = last_message["content"] + "\n" + SteamLobbies.get_lobby_member_name(chat_message["sender"]) + ": " + chat_message["content"]
			chat_log.append(last_message)
		else:
			chat_log.append(last_message)
			chat_log.append(chat_message)
	else:
		chat_log.append(chat_message)
	
	if chat_log.size() > max_log_size and max_log_size != -1:
		var new_archive: Dictionary = chat_log.pop_front()
		if new_archive["type"] == "chat_message":
			chat_archive = chat_archive + "\n" + SteamLobbies.get_lobby_member_name(new_archive["sender"]) + ": " + new_archive["content"]
		else:
			chat_archive = chat_archive + "\n" + new_archive["type"] + ": " + new_archive["content"]
