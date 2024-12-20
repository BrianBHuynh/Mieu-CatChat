extends Control
var player_list: Array = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	populate_player_list()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func populate_player_list() -> void:
	SteamLobbies.get_lobby_members()
	for player_id: int in SteamLobbies.lobby_members:
		var hbox: HBoxContainer = HBoxContainer.new()
		hbox.clip_contents = true
		var player_info: RichTextLabel = RichTextLabel.new()
		player_info.text = "Name: " + str(SteamLobbies.lobby_members[player_id]["steam_name"])
		player_info.set_script(load("res://current/scripts/node/rich_text_label.gd"))
		player_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		player_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		player_info.fit_content = true
		hbox.add_child(player_info)
		
		if player_id != SteamLobbies.host() and SteamLobbies.is_host():
			hbox.add_child(create_button(SteamLobbies.ban_player_temp.bind(player_id)))
			hbox.add_child(create_button(SteamLobbies.ban_player_persist.bind(player_id)))
			hbox.add_child(create_button(SteamLobbies.block_player.bind(player_id)))
		
		$ScrollContainer/VBoxContainer.add_child(hbox)


func _on_filter_pressed() -> void:
	Controls.open_menu("res://current/menus/chat_menus/chat_filter/chat_filter_menu.tscn")

func create_button(callable: Callable) -> Button:
	var button: Button = Button.new()
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_stretch_ratio = .1
	button.pressed.connect(callable)
	return button
