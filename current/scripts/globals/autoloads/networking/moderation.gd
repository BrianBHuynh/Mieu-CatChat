extends Node


var banned_players: Dictionary = {}


func _ready() -> void:
	load_finished()
	SignalBus.load_finished.connect(load_finished)


func load_finished() -> void:
	banned_players = Saves.get_or_return("networking", "persist_banned", {})


func is_allowed(ID: String) -> bool:
	return !(banned_players.has(ID) or Saves.get_or_return("networking", "blocked", {}).has(ID))


func ban_player_persist(ID: String, reason: String = "No reason provided") -> void:
	if SteamLobbies.is_host():
		if not banned_players.has(ID):
			banned_players[ID] = SteamLobbies.lobby_members[ID]["steam_name"]
		
		if not Saves.get_or_add("networking", "persist_banned", {}).has(ID):
			Saves.get_or_add("networking", "persist_banned", {})[ID] = SteamLobbies.lobby_members[ID]["steam_name"]
		
		if SteamLobbies.lobby_members.has(ID) and P2P.kitties.has(ID):
			P2P.remove_kitty(ID)
		
		P2P.send_lobby_data()
		P2P.send_ban(ID, reason)


func ban_player_temp(ID: String, reason: String = "No reason provided") -> void:
	if SteamLobbies.is_host():
		if not banned_players.has(ID):
			banned_players[ID] = SteamLobbies.lobby_members[ID]["steam_name"]
		
		if SteamLobbies.lobby_members.has(ID) and P2P.kitties.has(ID):
			P2P.remove_kitty(ID)
		
		P2P.send_lobby_data()
		P2P.send_ban(ID, reason)


func kick(ID: String, reason: String) -> void:
	if SteamLobbies.is_host():
		P2P.send_kick(ID, reason)


func block_player(ID: String) -> void:
	if not Saves.get_or_add("networking", "persist_blocked", {}).has(ID):
		Saves.get_or_add("networking", "persist_blocked", {})[ID] = SteamLobbies.lobby_members[ID]["steam_name"]
