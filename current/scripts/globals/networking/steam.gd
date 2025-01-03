extends Node
var running: bool = false
var steam_id: int = 0
var steam_username: String = ""

func _ready() -> void:
	Steam.steamInit()
	if Steam.isSteamRunning():
		Multithreading.add_task(Steam.initRelayNetworkAccess)
		Multithreading.add_task(Steam.initAuthentication)
		Ui.show_system_message("Steam is running!")
		Ui.show_system_message("User: " + Steam.getFriendPersonaName(Steam.getSteamID()))
		steam_id = Steam.getSteamID()
		steam_username = Steam.getFriendPersonaName(Steam.getSteamID())
		running = true
	else:
		Ui.show_system_message("Steam is not running right now, online features may not work correctly!")
		running = false
