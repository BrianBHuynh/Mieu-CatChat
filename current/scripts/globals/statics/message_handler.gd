extends Node
class_name MessageHandler


static func data(sender: String, message: Dictionary) -> void:
	if (
		Helper.dict_type_check(message["payload"], "x", TYPE_FLOAT)
		and Helper.dict_type_check(message["payload"], "y", TYPE_FLOAT)
		and Helper.dict_type_check(message["payload"], "sprite_y", TYPE_FLOAT)
		and Helper.dict_type_check(message["payload"], "movement_id", TYPE_INT)
		and Helper.dict_type_check(message["payload"], "name", TYPE_STRING)
		):
		if !Helper.dict_type_check(message["payload"], "frame", TYPE_INT):
			message["payload"]["frame"] = -1
		
		if Networking.kitties.has(sender) :
			if WorldManager.has(sender):
				if Helper.dict_type_check(Networking.kitties, sender, Node2D):
					Networking.kitties[sender].move_to(Vector2(message["payload"]["x"], message["payload"]["y"]), message["payload"]["sprite_y"], message["payload"]["movement_id"], message["payload"]["frame"])
				else:
					Networking.spawn_kitty(message)
			else:
				Networking.remove_kitty(sender)
		elif WorldManager.has(sender):
			Networking.spawn_kitty(message)


static func minigame_data(sender: String, message: Dictionary) -> void:
	if MinigameManager.has(sender):
		MinigameManager.accept_minigame_data(message)


static func chat(sender: String, message: Dictionary) -> void:
	if Helper.dict_type_check(message["payload"], "text", TYPE_STRING):
		Ui.show_chat_message(ChatFilter.filter(message))


static func lobby_data(sender: String, message: Dictionary) -> void:
	#This is currently steam only
	if (
	int(sender) == Steam.getLobbyOwner(SteamLobbies.lobby_id)
	and Helper.dict_type_check(message["payload"], "lobby_data", TYPE_DICTIONARY)
	and Helper.dict_type_check(message["payload"]["lobby_data"], "banned_players", TYPE_DICTIONARY)
	):
		Moderation.banned_players = message["payload"]["lobby_data"]["banned_players"]
		for player_id: String in Moderation.banned_players:
			if SteamLobbies.lobby_members.has(player_id) or Networking.kitties.has(player_id):
				Networking.remove_kitty(player_id)
				if player_id.begins_with("Steam"):
					Steam.closeSessionWithUser(int(player_id))
				SteamLobbies.lobby_members.erase(player_id)


static func ban(sender: String, message: Dictionary) -> void:
	pass
	#if sender == Steam.getLobbyOwner(SteamLobbies.lobby_id):
		#SteamLobbies.leave_lobby()
		#Ui.show_system_message("You were banned from the lobby")
		#Ui.show_system_message("Reason provided: " + str(message["payload"]["reason"]))


static func ban_announce(sender: String, message: Dictionary) -> void:
	pass
	#if (
	#sender == Steam.getLobbyOwner(SteamLobbies.lobby_id)
	#and Helper.dict_type_check(message["payload"], "banned_player", TYPE_INT)
	#):
		#Ui.show_system_message("The lobby owner " + SteamLobbies.get_host_name() + "has banned " + SteamLobbies.get_lobby_member_name(message["payload"]["banned_player"]))


static func kick(sender: String, message: Dictionary) -> void:
	pass
	#if sender == Steam.getLobbyOwner(SteamLobbies.lobby_id):
		#SteamLobbies.leave_lobby()
		#Ui.show_system_message("You were kicked from the lobby")
		#if Helper.dict_type_check(message["payload"], "reason", TYPE_STRING):
			#Ui.show_system_message("Reason provided: " + str(message["payload"]["reason"]))


static func kick_announce(sender: String, message: Dictionary) -> void:
	pass
	#if (
	#sender == Steam.getLobbyOwner(SteamLobbies.lobby_id) 
	#and Helper.dict_type_check(message["payload"], "kicked_player", TYPE_INT)
	#):
		#Ui.show_system_message("The lobby owner " + SteamLobbies.get_host_name() + "has kicked " + SteamLobbies.get_lobby_member_name(message["payload"]["kicked_player"]))


static func world_info(sender: String, message: Dictionary) -> void:
	if (
	Helper.dict_type_check(message["payload"], "world_name", TYPE_STRING)
	and Helper.dict_type_check(message["payload"], "instance_id", TYPE_INT)
	):
		WorldManager.add_to_world(sender, message["payload"]["world_name"], message["payload"]["instance_id"])
		if WorldManager.has(sender) and GlobalVars.mieu != null and is_instance_valid(GlobalVars.mieu):
			GlobalVars.mieu.send_location(Steam.NETWORKING_SEND_RELIABLE_NO_NAGLE)


static func minigame_info(sender: String, message: Dictionary) -> void:
	if (
	Helper.dict_type_check(message["payload"], "minigame_name", TYPE_STRING)
	and Helper.dict_type_check(message["payload"], "minigame_instance_id", TYPE_INT)
	):
		MinigameManager.add_to_minigame(sender, message["payload"]["minigame_name"], message["payload"]["minigame_instance_id"])


static func encrypted_message(sender: String, message: Dictionary) -> void:
	if (
	Helper.dict_type_check(message["payload"], "message_id", TYPE_INT)
	and Helper.dict_type_check(message["payload"], "encrypted_payload", TYPE_PACKED_BYTE_ARRAY)
	):
		Cryptography.save_message(sender, message["payload"]["message_id"], message["payload"]["encrypted_payload"])


static func encrypted_key(sender: String, message: Dictionary) -> void:
	if (
	Helper.dict_type_check(message["payload"], "message_id", TYPE_INT)
	and Helper.dict_type_check(message["payload"], "key", TYPE_STRING)
	):
		Cryptography.decode_message(sender, message["payload"]["message_id"], message["payload"]["key"])


static func ping(sender: String, message: Dictionary) -> void:
	StabilityMitigator.pong(sender)


static func pong(sender: String, message: Dictionary) -> void:
	pass


#Message handler will need to be rewritten as messages may have message.identity or not depending on if they're from steam or not. This will require a full rewrite of this section of code which will begin soon.
