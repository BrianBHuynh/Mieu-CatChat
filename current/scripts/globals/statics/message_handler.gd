extends Node
class_name MessageHandler


static func data(message: Dictionary) -> void:
	if (Helper.dict_type_check(message["payload"], "x", "float")
		and Helper.dict_type_check(message["payload"], "y", "float")
		and Helper.dict_type_check(message["payload"], "sprite_y", "float")
		and Helper.dict_type_check(message["payload"], "movement_id", "int")
		):
		if !Helper.dict_type_check(message["payload"], "frame", "int"):
			message["payload"]["frame"] = -1
		if SteamP2P.kitties.has(message.identity) :
			if WorldManager.has(message.identity):
				if Helper.dict_type_check(SteamP2P.kitties, message.identity, "Node2D"):
					SteamP2P.kitties[message.identity].move_to(Vector2(message["payload"]["x"], message["payload"]["y"]), message["payload"]["sprite_y"], message["payload"]["movement_id"], message["payload"]["frame"])
				else:
					SteamP2P.spawn_kitty(message)
			else:
				SteamP2P.remove_kitty(message.identity)
		elif WorldManager.has(message.identity):
			SteamP2P.spawn_kitty(message)

static func minigame_data(message: Dictionary) -> void:
	if MinigameManager.has(message.identity):
		MinigameManager.accept_minigame_data(message)

static func chat(message: Dictionary) -> void:
	if Helper.dict_type_check(message["payload"], "text", "String"):
		Ui.show_chat_message(ChatFilter.filter(message))

static func lobby_data(message: Dictionary) -> void:
	if (
	message.identity == Steam.getLobbyOwner(SteamLobbies.lobby_id)
	and Helper.dict_type_check(message["payload"], "lobby_data", "Dictionary")
	and Helper.dict_type_check(message["payload"]["lobby_data"], "banned_players", "Dictionary")
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
	and Helper.dict_type_check(message["payload"], "banned_player", "int")
	):
		Ui.show_system_message("The lobby owner " + SteamLobbies.get_host_name() + "has banned " + Steam.getFriendPersonaName(message["payload"]["banned_player"]))

static func kick(message: Dictionary) -> void:
	if message.identity == Steam.getLobbyOwner(SteamLobbies.lobby_id):
		SteamLobbies.leave_lobby()
		Ui.show_system_message("You were kicked from the lobby")
		if Helper.dict_type_check(message["payload"], "reason", "String"):
			Ui.show_system_message("Reason provided: " + str(message["payload"]["reason"]))

static func kick_announce(message: Dictionary) -> void:
	if message.identity == Steam.getLobbyOwner(SteamLobbies.lobby_id) and Helper.dict_type_check(message["payload"], "kicked_player", "int"):
		Ui.show_system_message("The lobby owner " + SteamLobbies.get_host_name() + "has kicked " + Steam.getFriendPersonaName(message["payload"]["kicked_player"]))

static func world_info(message: Dictionary) -> void:
	if (Helper.dict_type_check(message["payload"], "world_name", "String")
	and Helper.dict_type_check(message["payload"], "instance_id", "int")
	):
		WorldManager.add_to_world(message.identity, message["payload"]["world_name"], message["payload"]["instance_id"])
		if WorldManager.has(message.identity) and GlobalVars.mieu != null and is_instance_valid(GlobalVars.mieu):
			GlobalVars.mieu.send_location(Steam.NETWORKING_SEND_RELIABLE_NO_NAGLE)

static func minigame_info(message: Dictionary) -> void:
	if (Helper.dict_type_check(message["payload"], "minigame_name", "String")
	and Helper.dict_type_check(message["payload"], "minigame_instance_id", "int")):
		MinigameManager.add_to_minigame(message.identity, message["payload"]["minigame_name"], message["payload"]["minigame_instance_id"])

static func encrypted_message(message: Dictionary) -> void:
	if (Helper.dict_type_check(message["payload"], "message_id", "int")
	and Helper.dict_type_check(message["payload"], "encrypted_payload", "PackedByteArray")
	):
		Cryptography.save_message(message.identity, message["payload"]["message_id"], message["payload"]["encrypted_payload"])

static func encrypted_key(message: Dictionary) -> void:
	if (Helper.dict_type_check(message["payload"], "message_id", "int")
	and Helper.dict_type_check(message["payload"], "key", "String")
	):
		Cryptography.decode_message(message.identity, message["payload"]["message_id"], message["payload"]["key"])
