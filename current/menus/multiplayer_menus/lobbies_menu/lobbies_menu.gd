extends Control


func _ready() -> void:
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	refresh_lobbies()

func _on_create_lobby_btn_pressed() -> void:
	SteamLobbies.create_lobby()

func refresh_lobbies() -> void:
	Steam.requestLobbyList()

func _on_multiplayer_settings_pressed() -> void:
	Ui.open_menu("res://current/menus/multiplayer_menus/players_list/players_list.tscn")

func _on_leave_lobby_pressed() -> void:
	SteamLobbies.leave_lobby()
