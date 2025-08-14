extends Node


var running: bool = false
var steam_id: String = "0"
var steam_username: String = "Player"


func _ready() -> void:
	Steam.steamInit()
	#Makes sure the game is owned and the user is running steam while logged in.
	if Steam.isSteamRunning() and Steam.loggedOn() and Steam.isSubscribed():
		Multithreading.add_task(Steam.initRelayNetworkAccess)
		Multithreading.add_task(Steam.initAuthentication)
		Ui.show_system_debug("Steam is running!")
		Ui.show_system_debug("User is " + SteamLobbies.get_lobby_member_name(Steam.getSteamID()))
		steam_id = UserIds.id_to_steam_id(Steam.getSteamID())
		steam_username = SteamLobbies.get_lobby_member_name(Steam.getSteamID())
		running = true
		check_command_line()
	else:
		Ui.show_system_warning("Steam is not running right now, online features may not work correctly!")


func _physics_process(delta: float) -> void:
	if running:
		Steam.run_callbacks()
		#SteamP2P.process(delta)


func check_command_line() -> void:
	#Not fully implemented, test later.
	var command_line: Array = OS.get_cmdline_args()
	if command_line.size() > 0 && command_line[0] == "+connect_lobby" && command_line[1] > 0:
		Ui.show_system_message("Joining lobby: " + command_line[1])
		SteamLobbies.join_lobby(int(command_line[1]))
