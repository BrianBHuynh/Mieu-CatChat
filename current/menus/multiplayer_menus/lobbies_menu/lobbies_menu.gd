extends Control


func _ready() -> void:
	if SteamWorks.running:
		Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
		refresh_lobbies()
	$ScrollContainer/HBoxContainer/LeftSide/UUID.text = "Networking UUID: " + str(Saves.get_or_add("networking", "UUID", randi()))


func _on_create_lobby_btn_pressed() -> void:
	if SteamWorks.running:
		SteamLobbies.create_lobby()


func refresh_lobbies() -> void:
	if SteamWorks.running:
		Steam.requestLobbyList()


func _on_multiplayer_settings_pressed() -> void:
	Ui.open_menu("res://current/menus/multiplayer_menus/players_list/players_list.tscn")


func _on_leave_lobby_pressed() -> void:
	if SteamWorks.running:
		SteamLobbies.leave_lobby()
