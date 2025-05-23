extends Control
var player_list: Array = []


func _ready() -> void:
	populate_player_list()

func _process(_delta: float) -> void:
	if !Input.is_action_pressed("player_list"):
		queue_free()

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
			hbox.add_child(Helper.create_button(Moderation.ban_player_temp.bind(player_id)))
			hbox.add_child(Helper.create_button(Moderation.ban_player_persist.bind(player_id)))
			hbox.add_child(Helper.create_button(Moderation.block_player.bind(player_id)))
		$ScrollContainer/VBoxContainer.add_child(hbox)
