extends Node


var lobby_id: int = 0
var lobby_members: Dictionary = {}
var lobby_members_max: int = 10
var lobby_vote_kick: bool = false

func _ready() -> void:
	Steam.join_requested.connect(_on_lobby_join_requested)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	Steam.persona_state_change.connect(_on_persona_change)

func create_lobby(type: int = Steam.LOBBY_TYPE_PUBLIC, max_players: int = 250) -> void:
	if lobby_id == 0:
		Steam.createLobby(type, max_players)
	else:
		Ui.show_system_message("You are currently already in a lobby!")

func _on_lobby_created(_connected: int, this_lobby_id: int) -> void:
	lobby_id = this_lobby_id
	Ui.show_system_message("Created a lobby: " + str(lobby_id))
	Steam.setLobbyJoinable(lobby_id, true)
	Steam.setLobbyData(lobby_id, "name", SteamWorks.steam_username + "'s Lobby")
	Steam.setLobbyData(lobby_id, "mode", "Multiplayer Lobby")

func _on_open_lobby_list_pressed() -> void:
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()

func _on_lobby_match_list(these_lobbies: Array) -> void:
	var lobby_buttons: Array = Ui.lobbies.get_children()
	for button: Button in lobby_buttons:
		button.queue_free()
		lobby_buttons.erase(button)
	for this_lobby: int in these_lobbies:
		var lobby_name: String = Steam.getLobbyData(this_lobby, "name")
		var lobby_mode: String = Steam.getLobbyData(this_lobby, "mode")
		var lobby_num_members: int = Steam.getNumLobbyMembers(this_lobby)
		var lobby_button: Button = Button.new()
		lobby_button.set_text("Lobby %s: %s [%s] - %s Player(s)" % [this_lobby, lobby_name, lobby_mode, lobby_num_members])
		lobby_button.set_size(Vector2(800, 50))
		lobby_button.set_name("lobby_%s" % this_lobby)
		lobby_button.connect("pressed", Callable(self, "join_lobby").bind(this_lobby))
		Ui.lobbies.add_child(lobby_button)

func join_lobby(this_lobby_id: int) -> void:
	Ui.show_system_message("Attempting to join lobby " + str(lobby_id))
	lobby_members.clear()
	Steam.joinLobby(this_lobby_id)

func _on_lobby_joined(this_lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		lobby_id = this_lobby_id
		get_lobby_members()
		WorldsTracker.send_world()
	else:
		var fail_reason: String
		match response:
			Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST: fail_reason = "This lobby no longer exists."
			Steam.CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED: fail_reason = "You don't have permission to join this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_FULL: fail_reason = "The lobby is now full."
			Steam.CHAT_ROOM_ENTER_RESPONSE_ERROR: fail_reason = "Uh... something unexpected happened!"
			Steam.CHAT_ROOM_ENTER_RESPONSE_LIMITED: fail_reason = "You cannot join due to having a limited account."
			Steam.CHAT_ROOM_ENTER_RESPONSE_CLAN_DISABLED: fail_reason = "This lobby is locked or disabled."
			Steam.CHAT_ROOM_ENTER_RESPONSE_COMMUNITY_BAN: fail_reason = "This lobby is community locked."
			Steam.CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU: fail_reason = "A user in the lobby has blocked you from joining."
			Steam.CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER: fail_reason = "A user you have blocked is in the lobby."
		Ui.show_system_warning("Failed to join this chat room: %s" % fail_reason)
		_on_open_lobby_list_pressed()

func _on_lobby_join_requested(this_lobby_id: int, friend_id: int) -> void:
	var owner_name: String = Steam.getFriendPersonaName(friend_id)
	Ui.show_system_message("Joining %s's lobby..." % owner_name)
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
		Ui.show_system_debug("A user (%s) had information change, update the lobby list" % this_steam_id)
		get_lobby_members()

func _on_lobby_chat_update(_this_lobby_id: int, change_id: int, _making_change_id: int, chat_state: int) -> void:
	if Moderation.is_allowed(change_id):
		var changer_name: String = Steam.getFriendPersonaName(change_id)
		if chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED:
			Ui.show_system_message("%s has joined the lobby." % changer_name)
			SteamP2P.send_lobby_data(change_id, "lobby_join")
		elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_LEFT:
			Ui.show_system_message("%s has left the lobby." % changer_name)
			SteamP2P.remove_kitty(change_id)
			WorldsTracker.remove_from_worlds(change_id)
		else:
			Ui.show_system_message("%s did... something." % changer_name)
		get_lobby_members()

func leave_lobby() -> void:
	if lobby_id != 0:
		Steam.leaveLobby(lobby_id)
		lobby_id = 0
		for this_member: int in lobby_members:
			if this_member != SteamWorks.steam_id:
				Steam.closeSessionWithUser(this_member)
		SteamP2P.remove_kitties()
		lobby_members.clear()
		WorldsTracker.clear_worlds()

func is_host() -> bool:
	return host() == SteamWorks.steam_id

func host() -> int:
	return Steam.getLobbyOwner(lobby_id)

func get_host_name() -> String:
	return lobby_members[host()]["steam_name"]
