extends Node
class_name MessageHandler


static func data(message: Dictionary) -> void:
	if SteamP2P.kitties.has(message.identity) :
		if WorldManager.has(message.identity, WorldManager.current_world_name) and message.payload.has("dimensions") and WorldManager.dimensions == message.payload["dimensions"]:
			match message.payload["dimensions"]:
				3:
					if SteamP2P.kitties[message.identity] != null and SteamP2P.kitties[message.identity] is Node3D:
						SteamP2P.kitties[message.identity].move_to(Vector3(message.payload.x, message.payload.y, message.payload.z))
					else:
						SteamP2P.spawn_kitty(message)
				2:
					if SteamP2P.kitties[message.identity] != null and SteamP2P.kitties[message.identity] is Node2D:
						SteamP2P.kitties[message.identity].move_to(Vector2(message.payload.x, message.payload.y))
					else:
						SteamP2P.spawn_kitty(message)
				_:
					Ui.show_system_debug("Error reading locational data")
					SteamP2P.remove_kitty(message.identity)
		else:
			SteamP2P.remove_kitty(message.identity)
	elif WorldManager.has(message.identity, WorldManager.current_world_name):
		SteamP2P.spawn_kitty(message)

static func minigame_data(message: Dictionary) -> void:
	if (message["payload"].has("minigame_name") and message["payload"].has("minigame_instance_id")
	and MinigameManager.minigame_name == str(message["payload"]["minigame_name"]) && MinigameManager.minigame_instance_id == message["payload"]["minigame_instance_id"]
	):
		MinigameManager.accept_minigame_data(message)

static func chat(message: Dictionary) -> void:
	Ui.show_chat_message(ChatFilter.filter(message))

static func lobby_data(message: Dictionary) -> void:
	if (
	message.identity == Steam.getLobbyOwner(SteamLobbies.lobby_id)
	and message["payload"].has("lobby_data") and message["payload"]["lobby_data"] is Dictionary
	and message["payload"]["lobby_data"].has("banned_players") and message["payload"]["lobby_data"]["banned_players"] is Dictionary
	):
		Moderation.banned_players = message["payload"]["lobby_data"]["banned_players"]
		for player_id: int in Moderation.banned_players:
			if SteamLobbies.lobby_members.has(player_id) or SteamP2P.kitties.has(player_id):
				SteamP2P.remove_kitty(player_id)
				Steam.closeSessionWithUser(player_id)
				SteamLobbies.lobby_members.erase(player_id)

static func ban(message: Dictionary) -> void:
	if message.identity == Steam.getLobbyOwner(SteamLobbies.lobby_id):
		SteamLobbies.leave_lobby()
		Ui.show_system_message("You were banned from the lobby")
		Ui.show_system_message("Reason provided: " + str(message["payload"]["reason"]))

static func ban_announce(message: Dictionary) -> void:
	if (
	message.identity == Steam.getLobbyOwner(SteamLobbies.lobby_id)
	and message["payload"].has("banned_player") and message["payload"]["banned_player"] is int
	):
		Ui.show_system_message("The lobby owner " + SteamLobbies.get_host_name() + "has banned " + Steam.getFriendPersonaName(message["payload"]["banned_player"]))

static func kick(message: Dictionary) -> void:
	if message.identity == Steam.getLobbyOwner(SteamLobbies.lobby_id):
		SteamLobbies.leave_lobby()
		Ui.show_system_message("You were kicked from the lobby")
		if message["payload"].has("reason") and message["payload"]["reason"] is String:
			Ui.show_system_message("Reason provided: " + str(message["payload"]["reason"]))

static func kick_announce(message: Dictionary) -> void:
	if message.identity == Steam.getLobbyOwner(SteamLobbies.lobby_id) and message["payload"]["kicked_player"] is int:
		Ui.show_system_message("The lobby owner " + SteamLobbies.get_host_name() + "has kicked " + Steam.getFriendPersonaName(message["payload"]["kicked_player"]))

static func world_info(message: Dictionary) -> void:
	if message["payload"].has("world"):
		WorldManager.add_to_world(message.identity, str(message["payload"]["world"]))

static func encrypted_message(message: Dictionary) -> void:
	if (message["payload"].has("message_id") and message["payload"]["message_id"] is int
	and message["payload"].has("encrypted_payload") and message["payload"]["encrypted_payload"] is PackedByteArray
	):
		Cryptography.save_message(message.identity, message["payload"]["message_id"], message["payload"]["encrypted_payload"])

static func encrypted_key(message: Dictionary) -> void:
	if (message["payload"].has("message_id") and message["payload"]["message_id"] is int
	and message["payload"].has("key") and message["payload"]["key"] is String
	):
		Cryptography.decode_message(message.identity, message["payload"]["message_id"], message["payload"]["key"])
