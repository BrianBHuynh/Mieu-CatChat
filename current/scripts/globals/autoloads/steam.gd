extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Steam.steamInit()
	if Steam.isSteamRunning():
		print("Steam is running")
		print(Steam.getFriendPersonaName(Steam.getSteamID()))
	else:
		push_warning("Steam is not running right now!")
