extends Control


func _ready() -> void:
	Ui.chat_box = self
	$CheckBox.set_pressed_no_signal(Saves.get_or_return("settings", "auto_scroll", true))
	SignalBus.load_finished.connect(load_finished)
	for message: Dictionary in Ui.chat_log:
		match message["type"]:
			"chat_message":
				add_chat_message(message["sender"], message["target"], message["content"], message["private"], false)
			_:
				show_system_message(message["content"], message["color"], false, message["type"])

func load_finished() -> void:
	$CheckBox.set_pressed_no_signal(Saves.get_or_return("settings", "auto_scroll", true))

func show_chat_message(message: Dictionary) -> void:
	add_chat_message(message.identity, SteamWorks.steam_id, message["payload"]["text"], message["payload"]["private"])

func sent_chat_message(message: String, target: int = true, private: bool = false) -> void:
	add_chat_message(SteamWorks.steam_id, target, message, private)

func add_chat_message(sender: int, target: int, content: String, private: bool, save: bool = true) -> void:
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.clip_contents = true
	var message_text: RichTextLabel = RichTextLabel.new()
	if private:
		message_text.set_text("(whisper)" + Steam.getFriendPersonaName(sender) + ": " + content)
	else:
		if SteamWorks.running == true:
			message_text.set_text(Steam.getFriendPersonaName(sender) + ": " + content)
		else:
			message_text.set_text("You" + ": " + content)
	print(message_text.text)
	message_text.set_script(load("res://current/scripts/node/chat_message.gd"))
	message_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	message_text.fit_content = true
	hbox.add_child(message_text)
	
	var interact_button: Button = Button.new()
	interact_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	interact_button.size_flags_stretch_ratio = .1
	interact_button.pressed.connect(_delete_chat.bind(hbox))
	hbox.add_child(interact_button)
	if Ui.chat_box == self and self.is_inside_tree():
		$ScrollContainer/VBoxContainer.add_child(hbox)
		if save:
			Ui.chat_log.append({"type": "chat_message", "sender": sender, "target": target, "content": content, "private": private})
		if Saves.get_or_add("settings", "auto_scroll", true):
			await get_tree().create_timer(.05).timeout
			create_tween().tween_property($ScrollContainer.get_v_scroll_bar(), "value", $ScrollContainer.get_v_scroll_bar().max_value, 1.0)

func show_system_message(content: String, color: Color = Color.DARK_BLUE, save: bool = true, prefix: String = "SYSTEM") -> void:
	var message_text: RichTextLabel = RichTextLabel.new()
	if !prefix.is_empty():
		message_text.text = prefix + ": " + content
	else:
		message_text.text = content
	message_text.set_script(load("res://current/scripts/node/chat_message.gd"))
	message_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	message_text.add_theme_color_override("default_color", color)
	message_text.fit_content = true
	$ScrollContainer/VBoxContainer.add_child(message_text)
	if save:
		Ui.chat_log.append({"type": prefix, "content": content, "color": color})
		print(message_text.text)
	if Saves.get_or_add("settings", "auto_scroll", true) and WorldsTracker.first_world_started:
		await get_tree().create_timer(.05).timeout
		create_tween().tween_property($ScrollContainer.get_v_scroll_bar(), "value", $ScrollContainer.get_v_scroll_bar().max_value, 1.0)

func show_system_warning(content: String, color: Color = Color.DARK_RED, save: bool = true) -> void:
	show_system_message(content, color, save, "SYSTEM_WARNING")

func show_system_debug(content: String, color: Color = Color.SLATE_GRAY, save: bool = true) -> void:
	if Saves.get_or_return("settings", "show_debug", false):
		show_system_message(content, color, save, "DEBUG")

func release_input_focus() -> void:
	$TextBox.release_focus()

func open_text_input() -> void:
	$TextBox.grab_focus()

func is_text_box_focused() -> bool:
	return $TextBox.has_focus()

func _on_send_pressed() -> void:
	release_input_focus()
	if WorldsTracker.dimensions == 3:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if !$TextBox.text == "":
		SteamP2P.send_chat_message($TextBox.text)
	$TextBox.clear()

func _on_text_box_text_changed() -> void:
	if $TextBox.text.contains('\n'):
		$TextBox.text = $TextBox.text.erase($TextBox.text.length()-1, 1)
		_on_send_pressed()

func _delete_chat(chat: HBoxContainer) -> void:
	chat.queue_free()

func _on_auto_scroll_box_toggled(toggled_on: bool) -> void:
	Saves.set_value("settings", "auto_scroll", toggled_on)
