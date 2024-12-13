extends Node
#Currently heavily based on code from https://godotsteam.com/tutorials/lobbies/

#var lobby_data
var lobby_id: int = 0
var lobby_members: Dictionary = {}
var lobby_members_max: int = 10
var lobby_vote_kick: bool = false
var banned_players: Array[int] = Saves.get_or_add("networking", "persist_banned", Array([], TYPE_INT, "", null))
var blocked_players: Array[int] = Saves.get_or_add("networking", "persist_blocked", Array([], TYPE_INT, "", null))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Steam.join_requested.connect(_on_lobby_join_requested)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	Steam.lobby_created.connect(_on_lobby_created)
	#Steam.lobby_data_update.connect(_on_lobby_data_update)
	#Steam.lobby_invite.connect(_on_lobby_invite)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	#Steam.lobby_message.connect(_on_lobby_message)
	Steam.persona_state_change.connect(_on_persona_change)
	check_command_line()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func host() -> int:
	return Steam.getLobbyOwner(lobby_id)

func check_command_line() -> void:
	var command_line: Array = OS.get_cmdline_args()
	if command_line.size() > 0 && command_line[0] == "+connect_lobby" && command_line[1] > 0:
		print("Command line lobby ID: %s" % command_line[1])
		#join_lobby(int(command_line[1]))

func create_lobby(type: int, max_players: int) -> void:
	print(lobby_id)
	if lobby_id == 0:
		Steam.createLobby(type, max_players)

func _on_lobby_created(_connected: int, this_lobby_id: int) -> void:
	lobby_id = this_lobby_id
	Controls.show_system_message("Created a lobby: %s" % lobby_id)
	Steam.setLobbyJoinable(lobby_id, true)
	Steam.setLobbyData(lobby_id, "name", SteamWorks.steam_username + "'s Lobby")
	Steam.setLobbyData(lobby_id, "mode", "GodotSteam test")

func _on_open_lobby_list_pressed() -> void:
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	print("Requesting a lobby list")
	Steam.requestLobbyList()

func _on_lobby_match_list(these_lobbies: Array) -> void:
	var lobby_buttons: Array = Controls.lobbies.get_children()
	for button: Button in lobby_buttons:
		button.queue_free()
	for this_lobby: int in these_lobbies:
		var lobby_name: String = Steam.getLobbyData(this_lobby, "name")
		var lobby_mode: String = Steam.getLobbyData(this_lobby, "mode")
		var lobby_num_members: int = Steam.getNumLobbyMembers(this_lobby)
		var lobby_button: Button = Button.new()
		lobby_button.set_text("Lobby %s: %s [%s] - %s Player(s)" % [this_lobby, lobby_name, lobby_mode, lobby_num_members])
		lobby_button.set_size(Vector2(800, 50))
		lobby_button.set_name("lobby_%s" % this_lobby)
		lobby_button.connect("pressed", Callable(self, "join_lobby").bind(this_lobby))
		Controls.lobbies.add_child(lobby_button)

func join_lobby(this_lobby_id: int) -> void:
	print("Attempting to join lobby %s" % lobby_id)
	lobby_members.clear()
	Steam.joinLobby(this_lobby_id)

func _on_lobby_joined(this_lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		lobby_id = this_lobby_id
		get_lobby_members()
		make_p2p_handshake()
	else:
		var fail_reason: String
		match response:
			Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST: fail_reason = "This lobby no longer exists."
			Steam.CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED: fail_reason = "You don't have permission to join this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_FULL: fail_reason = "The lobby is now full."
			Steam.CHAT_ROOM_ENTER_RESPONSE_ERROR: fail_reason = "Uh... something unexpected happened!"
			Steam.CHAT_ROOM_ENTER_RESPONSE_BANNED: fail_reason = "You are banned from this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_LIMITED: fail_reason = "You cannot join due to having a limited account."
			Steam.CHAT_ROOM_ENTER_RESPONSE_CLAN_DISABLED: fail_reason = "This lobby is locked or disabled."
			Steam.CHAT_ROOM_ENTER_RESPONSE_COMMUNITY_BAN: fail_reason = "This lobby is community locked."
			Steam.CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU: fail_reason = "A user in the lobby has blocked you from joining."
			Steam.CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER: fail_reason = "A user you have blocked is in the lobby."
		Controls.show_system_message("Failed to join this chat room: %s" % fail_reason)
		_on_open_lobby_list_pressed()

func _on_lobby_join_requested(this_lobby_id: int, friend_id: int) -> void:
	var owner_name: String = Steam.getFriendPersonaName(friend_id)
	Controls.show_system_message("Joining %s's lobby..." % owner_name)
	join_lobby(this_lobby_id)

func get_lobby_members() -> void:
	lobby_members.clear()
	var num_of_members: int = Steam.getNumLobbyMembers(lobby_id)
	for this_member: int in range(0, num_of_members):
		var member_steam_id: int = Steam.getLobbyMemberByIndex(lobby_id, this_member)
		var member_steam_name: String = Steam.getFriendPersonaName(member_steam_id)
		lobby_members[member_steam_id] = {"steam_name": member_steam_name}
	
func _on_persona_change(this_steam_id: int, _flag: int) -> void:
	if lobby_id > 0:
		print("A user (%s) had information change, update the lobby list" % this_steam_id)
		get_lobby_members()

func make_p2p_handshake() -> void:
	print("Sending P2P handshake to the lobby")
	SteamP2P.sendMessageToUser(0, {"type": "Handshake", "message": "handshake", "from": SteamWorks.steam_id})

func _on_lobby_chat_update(_this_lobby_id: int, change_id: int, _making_change_id: int, chat_state: int) -> void:
	var changer_name: String = Steam.getFriendPersonaName(change_id)
	if chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED:
		Controls.show_system_message("%s has joined the lobby." % changer_name)
		SteamP2P.send_lobby_data(change_id)
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_LEFT:
		Controls.show_system_message("%s has left the lobby." % changer_name)
		if SteamP2P.kitties.has(change_id) and SteamP2P.kitties.get(change_id).is_inside_tree():
				get_parent().remove_child(SteamP2P.kitties.get(change_id))
				SteamP2P.kitties.erase(change_id)
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_KICKED:
		Controls.show_system_message("%s has been kicked from the lobby." % changer_name)
		if SteamP2P.kitties.has(change_id) and SteamP2P.kitties.get(change_id).is_inside_tree():
				get_parent().remove_child(SteamP2P.kitties.get(change_id))
				SteamP2P.kitties.erase(change_id)
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_BANNED:
		Controls.show_system_message("%s has been banned from the lobby." % changer_name)
		if SteamP2P.kitties.has(change_id) and SteamP2P.kitties.get(change_id).is_inside_tree():
				get_parent().remove_child(SteamP2P.kitties.get(change_id))
				SteamP2P.kitties.erase(change_id)
	else:
		Controls.show_system_message("%s did... something." % changer_name)
	get_lobby_members()

func leave_lobby() -> void:
	if lobby_id != 0:
		Steam.leaveLobby(lobby_id)
	lobby_id = 0
	for this_member: Dictionary in lobby_members:
		if this_member['steam_id'] != SteamWorks.steam_id:
			Steam.closeP2PSessionWithUser(this_member['steam_id'])
	lobby_members.clear()

func ban_player_persist(steam_id: int) -> void:
	if is_host():
		if not banned_players.has(steam_id):
			banned_players.append(steam_id)
		if not Saves.get_or_add("networking", "persist_banned", Array([], TYPE_INT, "", null)).has(steam_id):
			Saves.get_or_add("networking", "persist_banned", Array([], TYPE_INT, "", null)).append(steam_id)
		SteamP2P.send_lobby_data(0)
		
		if lobby_members.has(steam_id) and SteamP2P.kitties.has(steam_id):
			SteamP2P.kitties[steam_id].queue_free()

func ban_player_temp(steam_id: int) -> void:
	if is_host():
		if not banned_players.has(steam_id):
			banned_players.append(steam_id)
		SteamP2P.send_lobby_data(0)
		
		if lobby_members.has(steam_id) and SteamP2P.kitties.has(steam_id):
			SteamP2P.kitties[steam_id].queue_free()

func block_player(steam_id: int) -> void:
	if not Saves.get_or_add("networking", "persist_blocked", Array([], TYPE_INT, "", null)).has(steam_id):
		Saves.get_or_add("networking", "persist_blocked", Array([], TYPE_INT, "", null)).append(steam_id)

func is_host() -> bool:
	return Steam.getLobbyOwner(SteamLobbies.lobby_id) == SteamWorks.steam_id
