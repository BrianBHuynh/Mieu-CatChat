extends Control
var chat_messages: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Controls.chat_box = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func add_chat_message(message: Dictionary) -> void:
	var interactable_message: Button = Button.new()
	if message["payload"]["private"]:
		interactable_message.set_text("(whisper)" + SteamLobbies.lobby_members[message.identity]["steam_name"] + ": " + message["payload"]["text"])
	else:
		var text = SteamLobbies.lobby_members[message.identity]["steam_name"] + ": " + message["payload"]["text"]
		interactable_message.set_text(SteamLobbies.lobby_members[message.identity]["steam_name"] + ": " + message["payload"]["text"])
	interactable_message.set_script(load("res://current/scripts/node/chat_message.gd"))
	interactable_message.clip_contents = true
	$ScrollContainer/VBoxContainer.add_child(interactable_message)
	chat_messages.append(interactable_message)

func sent_chat_message(message: String, private: bool) -> void:
	var interactable_message: Button = Button.new()
	if private:
		interactable_message.set_text("(whisper)" + SteamWorks.steam_username + ": " + message)
	else:
		interactable_message.set_text(SteamWorks.steam_username + ": " + message)
	interactable_message.set_script(load("res://current/scripts/node/chat_message.gd"))
	interactable_message.clip_text = true
	$ScrollContainer/VBoxContainer.add_child(interactable_message)
	chat_messages.append(interactable_message)

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
