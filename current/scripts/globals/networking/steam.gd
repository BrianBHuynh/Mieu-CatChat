extends Node
var running: bool = false
var steam_id: int = 0
var steam_username: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Steam.steamInit()
	Multithreading.add_task(Steam.initRelayNetworkAccess)
	Multithreading.add_task(Steam.initAuthentication)
	
	if Steam.isSteamRunning():
		print("Steam is running")
		print(Steam.getFriendPersonaName(Steam.getSteamID()))
		steam_id = Steam.getSteamID()
		steam_username = Steam.getFriendPersonaName(Steam.getSteamID())
		running = true
	else:
		push_warning("Steam is not running right now!")
		running = false
