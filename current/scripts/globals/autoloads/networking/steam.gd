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
		check_command_line()
	else:
		Ui.show_system_message("Steam is not running right now, online features may not work correctly!")
		running = false

func _process(delta: float) -> void:
	Steam.run_callbacks()
	SteamP2P.process(delta)

func check_command_line() -> void:
	#Not fully implemented, test later.
	var command_line: Array = OS.get_cmdline_args()
	if command_line.size() > 0 && command_line[0] == "+connect_lobby" && command_line[1] > 0:
		Ui.show_system_message("Joining lobby: " + command_line[1])
		SteamLobbies.join_lobby(int(command_line[1]))
