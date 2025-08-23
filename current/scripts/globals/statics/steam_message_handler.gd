extends Node
class_name SteamMessageHandler


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
