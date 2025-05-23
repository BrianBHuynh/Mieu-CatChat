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
		var player_info: RichTextLabel = RichTextLabel.new()
		player_info.text = str(SteamLobbies.lobby_members[player_id]["steam_name"])
		player_info.set_script(load("res://current/scripts/node/rich_text_label.gd"))
		player_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		player_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		player_info.fit_content = true
		$ScrollContainer/VBoxContainer.add_child(player_info)
