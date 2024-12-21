extends Node
var running: bool = false
var steam_id: int = 0
var steam_username: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Steam.steamInit()
	
	if Steam.isSteamRunning():
		Multithreading.add_task(Steam.initRelayNetworkAccess)
		Multithreading.add_task(Steam.initAuthentication)
		print("Steam is running")
		print(Steam.getFriendPersonaName(Steam.getSteamID()))
		steam_id = Steam.getSteamID()
		steam_username = Steam.getFriendPersonaName(Steam.getSteamID())
		running = true
	else:
		push_warning("Steam is not running right now!")
		await get_tree().create_timer(1).timeout
		Controls.show_system_message("Steam is not running right now, online features may not work correctly!")
		running = false
