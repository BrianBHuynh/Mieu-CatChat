extends Control


func _ready() -> void:
	refresh_lobbies()


func _process(_delta: float) -> void:
	pass


func _on_create_lobby_btn_pressed() -> void:
	SteamLobbies.create_lobby(2, 250)


func refresh_lobbies() -> void:
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	print("Requesting a lobby list")
	Steam.requestLobbyList()


func _on_send_test_data_btn_pressed() -> void:
	Multithreading.add_task(Callable(SteamP2P.sendMessageToUser).bind(0, {"type": "ping", "send_time": Time.get_unix_time_from_system()}))


func _on_multiplayer_settings_pressed() -> void:
	Ui.open_menu("res://current/menus/multiplayer_menus/players_list/players_list.tscn")
