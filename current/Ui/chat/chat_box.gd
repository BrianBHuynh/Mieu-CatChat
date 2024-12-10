extends Control
var chat_messages: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Controls.chat_box = self
	$CheckBox.set_pressed_no_signal(Saves.get_or_add("settings", "auto_scroll", true))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func process_chat_message(message: Dictionary) -> void:
	add_chat_message(message.identity, SteamWorks.steam_id, message["payload"]["text"], message["payload"]["private"])

func sent_chat_message(message: String, private: bool, target: int) -> void:
	add_chat_message(SteamWorks.steam_id, target, message, private)

func add_chat_message(sender: int, target: int, content: String, private: bool) -> void:
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.clip_contents = true
	var message_text: RichTextLabel = RichTextLabel.new()
	if private:
		message_text.set_text("(whisper)" + Steam.getFriendPersonaName(sender) + ": " + content)
	else:
		message_text.set_text(Steam.getFriendPersonaName(sender) + ": " + content)
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
	$ScrollContainer/VBoxContainer.add_child(hbox)
	chat_messages.append({"sender": sender, "target": target, "content": content, "private": private, "chat": hbox})
	if Saves.get_or_add("settings", "auto_scroll", true):
		await get_tree().create_timer(.05).timeout
		create_tween().tween_property($ScrollContainer.get_v_scroll_bar(), "value", $ScrollContainer.get_v_scroll_bar().max_value, 1.0)

#Current button sizing problems are solved in this commit which is already commited into the main repo, should be fixed in 4.4 https://github.com/godotengine/godot/commit/0f98b3244805d61ef9edcfa4671ab77c1c5167a7
func release_input_focus() -> void:
	$TextBox.release_focus()

func open_text_input() -> void:
	$TextBox.grab_focus()

func is_text_box_focused() -> bool:
	return $TextBox.has_focus()

func _on_send_pressed() -> void:
	release_input_focus()
	if !$TextBox.text == "":
		SteamP2P.send_chat_message(0, $TextBox.text, false)
	$TextBox.clear()

func _on_text_box_text_changed() -> void:
	if $TextBox.text.contains('\n'):
		$TextBox.text = $TextBox.text.erase($TextBox.text.length()-1, 1)
		_on_send_pressed()

func _delete_chat(chat: HBoxContainer) -> void:
	chat.queue_free()


func _on_auto_scroll_box_toggled(toggled_on: bool) -> void:
	Saves.set_value("settings", "auto_scroll", toggled_on)
