extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_create_lobby_btn_pressed() -> void:
	Steamlobbies.create_lobby(2, 250)


func _on_list_lobby_btn_pressed() -> void:
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	print("Requesting a lobby list")
	Steam.requestLobbyList()


func _on_send_test_data_btn_pressed() -> void:
	Multithreading.add_task(Callable(SteamP2P.send_p2p_packet).bind(0, {"name" : "hello"}))
