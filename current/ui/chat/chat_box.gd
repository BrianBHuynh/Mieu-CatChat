extends Control


var latest_message: Variant

func _ready() -> void:
	Ui.chat_box = self
	$CheckBox.set_pressed_no_signal(Saves.get_or_return("settings", "auto_scroll", true))
	SignalBus.load_finished.connect(load_finished)
	show_system_message("Loading...", Color.LIGHT_STEEL_BLUE, false)
	Multithreading.add_task(load_messages)


func load_messages() -> void:
	var messages: Array = []
	for message: Dictionary in Ui.chat_log:
		match message["type"]:
			"chat_message":
				messages.append(create_chat_message(message["sender"], message["target"], message["content"], message["private"], false))
			_:
				messages.append(create_system_message(message["content"], message["color"], false, message["type"]))
	
	Ui.chat_box.add_messages.call_deferred(messages)


func add_messages(messages: Array) -> void:
	replace_first()
	for message: Control in messages:
		add_chat_label(message)


func replace_first() -> void:
	if $ScrollContainer/VBoxContainer.get_child_count() > 0:
		$ScrollContainer/VBoxContainer.get_child(0).text = Ui.chat_archive


func load_finished() -> void:
	$CheckBox.set_pressed_no_signal(Saves.get_or_return("settings", "auto_scroll", true))


func show_chat_message(message: Dictionary) -> void:
	add_chat_message(message.identity, SteamWorks.steam_id, message["payload"]["text"], message["payload"]["private"])


func sent_chat_message(message: String, target: int = 0, private: bool = false) -> void:
	add_chat_message(SteamWorks.steam_id, target, message, private)


func add_chat_message(sender: int, target: int, content: String, private: bool, save: bool = true) -> void:
	if (
	latest_message != null 
	and latest_message is HBoxContainer
	and latest_message.get_child(0).text.begins_with(SteamLobbies.get_lobby_member_name(sender))
	):
		var message_text: String
		if private:
			message_text = "(whisper)" + SteamLobbies.get_lobby_member_name(sender) + ": " + content
		else:
			if SteamWorks.running == true:
				message_text = SteamLobbies.get_lobby_member_name(sender) + ": " + content
			else:
				message_text = "You" + ": " + content
		
		latest_message.get_child(0).text = latest_message.get_child(0).text + "\n" + message_text
		Ui.chat_log_add({"type": "chat_message", "sender": sender, "target": target, "content": content, "private": private})
	else:
		var message: RichTextLabel = create_chat_message(sender, target, content, private, save)
		if Ui.chat_box != null and Ui.chat_box.is_inside_tree():
			Ui.chat_box.add_chat_label(message)
			if save:
				print(content)
				Ui.chat_log_add({"type": "chat_message", "sender": sender, "target": target, "content": content, "private": private})
			
			if Saves.get_or_add("settings", "auto_scroll", true):
				scroll_down()
		
		latest_message = message


func create_chat_message(sender: int, _target: int, content: String, private: bool, _save: bool = true) -> RichTextLabel:
	var chat_message: RichTextLabel = RichTextLabel.new()
	if private:
		chat_message.set_text("(whisper)" + SteamLobbies.get_lobby_member_name(sender) + ": " + content)
	else:
		if SteamWorks.running == true:
			chat_message.set_text(SteamLobbies.get_lobby_member_name(sender) + ": " + content)
		else:
			chat_message.set_text("You" + ": " + content)
	
	chat_message.set_script(load("res://current/scripts/node/chat_message.gd"))
	chat_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	chat_message.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chat_message.fit_content = true
	return chat_message


func add_chat_label(message: RichTextLabel) -> void:
	$ScrollContainer/VBoxContainer.add_child(message)


func scroll_down() -> void:
	await get_tree().create_timer(.05).timeout
	create_tween().tween_property($ScrollContainer.get_v_scroll_bar(), "value", $ScrollContainer.get_v_scroll_bar().max_value, 1.0)


func show_system_message(content: String, color: Color = Color.DEEP_SKY_BLUE, save: bool = true, prefix: String = "SYSTEM") -> void:
	if (
	latest_message != null 
	and latest_message is RichTextLabel
	and latest_message.get_theme_color("default_color") == color
	):
		latest_message.text = latest_message.text + "\n" + prefix + ": " + content
	else:
		var message: RichTextLabel = create_system_message(content, color, save, prefix)
		if Ui.chat_box != null and Ui.chat_box.is_inside_tree():
			Ui.chat_box.add_chat_label(message)
			print(content)
			if save:
				Ui.chat_log_add({"type": prefix, "content": content, "color": color})
			if Saves.get_or_add("settings", "auto_scroll", true) and WorldManager.first_world_started:
				scroll_down()
		
		latest_message = message


func create_system_message(content: String, color: Color = Color.DEEP_SKY_BLUE, _save: bool = true, prefix: String = "SYSTEM") -> RichTextLabel:
	var system_message: RichTextLabel = RichTextLabel.new()
	if !prefix.is_empty():
		system_message.text = prefix + ": " + content
	else:
		system_message.text = content
	
	system_message.set_script(load("res://current/scripts/node/chat_message.gd"))
	system_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	system_message.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	system_message.add_theme_color_override("default_color", color)
	if Saves.get_or_return("settings", "invert_outline", false):
		system_message.add_theme_color_override("font_outline_color", get_theme_color("default_color").inverted())
	
	system_message.fit_content = true
	return system_message


func show_system_warning(content: String, color: Color = Color.DARK_RED, save: bool = false) -> void:
	show_system_message(content, color, save, "SYSTEM_WARNING")


func show_system_debug(content: String, color: Color = Color.DARK_SLATE_BLUE, save: bool = false) -> void:
	if Saves.get_or_return("settings", "show_debug", false):
		show_system_message(content, color, save, "DEBUG")


func release_input_focus() -> void:
	if $TextBox.is_inside_tree():
		$TextBox.release_focus()


func open_text_input() -> void:
	$TextBox.grab_focus()


func is_text_box_focused() -> bool:
	return $TextBox.has_focus()


func _on_send_pressed() -> void:
	release_input_focus()
	if !$TextBox.text == "":
		SteamP2P.send_chat_message($TextBox.text)
	
	$TextBox.clear()


func _on_text_box_text_changed() -> void:
	if $TextBox.text.contains('\n'):
		$TextBox.text = $TextBox.text.erase($TextBox.text.length()-1, 1)
		_on_send_pressed()


func _delete_chat(chat: HBoxContainer, sender: int, target: int, content: String, private: bool, _save: bool = true) -> void:
	Ui.erase_chat({"type": "chat_message", "sender": sender, "target": target, "content": content, "private": private})
	chat.queue_free()


func _on_auto_scroll_box_toggled(toggled_on: bool) -> void:
	Saves.set_value("settings", "auto_scroll", toggled_on)
