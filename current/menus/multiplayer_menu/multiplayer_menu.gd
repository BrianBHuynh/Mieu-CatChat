extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	refresh_lobbies()


# Called every frame. 'delta' is the elapsed time since the previous frame.
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
