extends Node


var banned_players: Dictionary = {}

func _ready() -> void:
	load_finished()
	SignalBus.load_finished.connect(load_finished)

func load_finished() -> void:
	banned_players = Saves.get_or_return("networking", "persist_banned", {})

func is_allowed(pid: int) -> bool:
	return !(banned_players.has(pid) or Saves.get_or_return("networking", "blocked", {}).has(pid))

func ban_player_persist(steam_id: int, reason: String = "No reason provided") -> void:
	if SteamLobbies.is_host():
		if not banned_players.has(steam_id):
			banned_players[steam_id] = SteamLobbies.lobby_members[steam_id]["steam_name"]
		if not Saves.get_or_add("networking", "persist_banned", {}).has(steam_id):
			Saves.get_or_add("networking", "persist_banned", {})[steam_id] = SteamLobbies.lobby_members[steam_id]["steam_name"]
		if SteamLobbies.lobby_members.has(steam_id) and SteamP2P.kitties.has(steam_id):
			SteamP2P.remove_kitty(steam_id)
		SteamP2P.send_lobby_data()
		SteamP2P.send_ban(steam_id, reason)

func ban_player_temp(steam_id: int, reason: String = "No reason provided") -> void:
	if SteamLobbies.is_host():
		if not banned_players.has(steam_id):
			banned_players[steam_id] = SteamLobbies.lobby_members[steam_id]["steam_name"]
		if SteamLobbies.lobby_members.has(steam_id) and SteamP2P.kitties.has(steam_id):
			SteamP2P.remove_kitty(steam_id)
		SteamP2P.send_lobby_data()
		SteamP2P.send_ban(steam_id, reason)

func kick(steam_id: int, reason: String) -> void:
	if SteamLobbies.is_host():
		SteamP2P.send_kick(steam_id, reason)

func block_player(steam_id: int) -> void:
	if not Saves.get_or_add("networking", "persist_blocked", {}).has(steam_id):
		Saves.get_or_add("networking", "persist_blocked", {})[steam_id] = SteamLobbies.lobby_members[steam_id]["steam_name"]
