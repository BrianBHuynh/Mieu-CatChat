extends Node


var kitties: Dictionary = {}

func _ready() -> void:
	Steam.network_messages_session_request.connect(_on_network_messages_session_request)
	Steam.network_messages_session_failed.connect(_on_p2p_session_connect_fail)

func process(_delta: float) -> void:
	if SteamLobbies.lobby_id > 0:
		read_p2p_messages()

func _on_network_messages_session_request(remote_id: int) -> void:
	if Moderation.is_allowed(remote_id):
		Steam.acceptSessionWithUser(remote_id)
		WorldsTracker.send_world(remote_id)

func read_p2p_messages() -> void:
	var messages: Array = Steam.receiveMessagesOnChannel(0, 1000)
	if messages.size() == 0:
		pass
	else:
		for message: Dictionary in messages:
			if message.is_empty() or message == null:
				Ui.show_system_debug("WARNING: read an empty packet with non-zero size!")
			elif !Moderation.is_allowed(message.identity):
				Ui.show_system_debug("Message from blocked or banned player")
				Steam.closeSessionWithUser(message.identity)
				remove_kitty(message.identity)
			else:
				message.payload = bytes_to_var(message.payload.decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP))
				match message["payload"]["type"]:
					"data":
						if kitties.has(message.identity):
							if WorldsTracker.has(WorldsTracker.current_world, message.identity) and WorldsTracker.dimensions == message.payload["dimensions"]:
								if message.payload["dimensions"] == 3 and kitties[message.identity] is Node3D:
									kitties[message.identity].move_to(Vector3(message.payload.x, message.payload.y, message.payload.z))
								elif message.payload["dimensions"] == 2 and kitties[message.identity] is Node2D:
									kitties[message.identity].move_to(Vector2(message.payload.x, message.payload.y))
								else:
									Ui.show_system_message("Error reading locational data")
									remove_kitty(message.identity)
							else:
								remove_kitty(message.identity)
						elif WorldsTracker.has(WorldsTracker.current_world, message.identity):
							if WorldsTracker.dimensions == 3 and message.payload["dimensions"] == 3 and get_tree().current_scene is Node3D:
								var file: Resource = load("res://current/characters/3D/mieu_peer/mieu_peer.tscn")
								var kit: Node3D = file.instantiate()
								get_parent().add_child(kit)
								kit.sign_adoption(message["identity"])
								kitties[message["identity"]] = kit
								Ui.show_system_message("creating", Color.GREEN)
								kitties[message.identity].global_position = Vector3(message.payload.x, message.payload.y, message.payload.z)
							elif WorldsTracker.dimensions == 2 and message.payload["dimensions"] == 2 and get_tree().current_scene is Node2D:
								while !WorldsTracker.middleground:
									await get_tree().process_frame
								var file: Resource = load("res://current/characters/2D/mieu_peer/mieu_peer.tscn")
								var kit: Node2D = file.instantiate()
								WorldsTracker.middleground.add_child(kit)
								kit.sign_adoption(message["identity"])
								kitties[message["identity"]] = kit
								Ui.show_system_message("creating", Color.GREEN)
								kitties[message.identity].global_position = Vector2(message.payload.x, message.payload.y)
					"chat":
						Ui.show_chat_message(ChatFilter.filter(message))
					"lobby_data":
						if message.identity == Steam.getLobbyOwner(SteamLobbies.lobby_id):
							Moderation.banned_players = message["payload"]["lobby_data"]["banned_players"]
							for player_id: String in Moderation.banned_players:
								var player_id_int: int = player_id.to_int()
								if SteamLobbies.lobby_members.has(player_id_int) or kitties.has(player_id_int):
									remove_kitty(player_id_int)
									Steam.closeSessionWithUser(player_id_int)
									SteamLobbies.lobby_members.erase(player_id_int)
					"ban":
						if message.identity == Steam.getLobbyOwner(SteamLobbies.lobby_id):
							SteamLobbies.leave_lobby()
							Ui.show_system_message("You were banned from the lobby")
							Ui.show_system_message("Reason provided: " + message["payload"]["reason"])
					"ban_announce":
						if message.identity == Steam.getLobbyOwner(SteamLobbies.lobby_id):
							Ui.show_system_message("The lobby owner " + SteamLobbies.get_host_name() + "has banned " + Steam.getFriendPersonaName(message["payload"]["banned_player"]))
					"kick":
						if message.identity == Steam.getLobbyOwner(SteamLobbies.lobby_id):
							SteamLobbies.leave_lobby()
							Ui.show_system_message("You were kicked from the lobby")
							Ui.show_system_message("Reason provided: " + message["payload"]["reason"])
					"kick_announce":
						if message.identity == Steam.getLobbyOwner(SteamLobbies.lobby_id):
							Ui.show_system_message("The lobby owner " + SteamLobbies.get_host_name() + "has kicked " + Steam.getFriendPersonaName(message["payload"]["kicked_player"]))
					"world_info":
						WorldsTracker.add_to_world(message["payload"]["world"], message.identity)

func sendMessageToUser(payload: Dictionary, this_target: int = 0, send_type: int = Steam.NETWORKING_SEND_RELIABLE, channel: int = 0) -> void:
	if SteamLobbies.lobby_members.size() > 1:
		var this_data: PackedByteArray
		this_data.append_array(var_to_bytes(payload))
		this_data = this_data.compress(FileAccess.COMPRESSION_GZIP)
		if this_target == 0:
			match payload["type"]:
				"data":
					for this_member: int in SteamLobbies.lobby_members:
						if this_member != SteamWorks.steam_id and WorldsTracker.has(WorldsTracker.current_world, this_member) and Moderation.is_allowed(this_member):
							Steam.sendMessageToUser(this_member, this_data, send_type, channel)
				_:
					for this_member: int in SteamLobbies.lobby_members:
						if this_member != SteamWorks.steam_id and Moderation.is_allowed(this_member):
							Steam.sendMessageToUser(this_member, this_data, send_type, channel)
		else:
			match payload["type"]:
				"ban", "kick":
					if this_target != SteamWorks.steam_id and SteamLobbies.is_host():
						Steam.sendMessageToUser(this_target, this_data, send_type, channel)
						await get_tree().create_timer(1).timeout
						Steam.closeSessionWithUser(this_target)
				_:
					if Moderation.is_allowed(this_target):
						Steam.sendMessageToUser(this_target, this_data, send_type, channel)

func send_chat_message(message: String, this_target: int = 0, private: bool = false, channel: int = 0) -> void:
	if SteamLobbies.lobby_members.size() > 1:
		var send_type: int = Steam.NETWORKING_SEND_RELIABLE
		var this_data: PackedByteArray
		this_data.append_array(var_to_bytes({"type": "chat", "text": message, "private": private}))
		this_data = this_data.compress(FileAccess.COMPRESSION_GZIP)
		if this_target == 0:
			for this_member: int in SteamLobbies.lobby_members:
				if this_member != SteamWorks.steam_id and Moderation.is_allowed(this_member):
					Steam.sendMessageToUser(this_member, this_data, send_type, channel)
		else:
			if Moderation.is_allowed(this_target):
				Steam.sendMessageToUser(this_target, this_data, send_type, channel)
			else:
				Ui.show_system_warning("Target is either blocked or banned!")
	Ui.sent_chat_message(message, this_target, private)

func send_lobby_data(this_target: int = 0, _reason: String = "No reason provided", channel: int = 0) -> void:
	if SteamLobbies.is_host() and SteamLobbies.lobby_members.size() > 1:
		var send_type: int = Steam.NETWORKING_SEND_RELIABLE
		var this_data: PackedByteArray
		this_data.append_array(var_to_bytes({"type": "lobby_data", "lobby_data": {"banned_players": Moderation.banned_players}}))
		this_data = this_data.compress(FileAccess.COMPRESSION_GZIP)
		if this_target == 0:
			for this_member: int in SteamLobbies.lobby_members:
				if this_member != SteamWorks.steam_id and Moderation.is_allowed(this_member):
					Steam.sendMessageToUser(this_member, this_data, send_type, channel)
		else:
			if this_target != SteamWorks.steam_id and Moderation.is_allowed(this_target):
					Steam.sendMessageToUser(this_target, this_data, send_type, channel)

func send_kick(this_target: int = 0, reason: String = "no reason provided") -> void:
	if SteamLobbies.is_host() and SteamLobbies.lobby_members.size() > 1:
		sendMessageToUser({"type": "kick", "reason": reason}, this_target)
		sendMessageToUser({"type": "kick_announce", "kicked_player": this_target}, 0)

func send_ban(this_target: int = 0, reason: String = "no reason provided") -> void:
	if SteamLobbies.is_host() and SteamLobbies.lobby_members.size() > 1:
		sendMessageToUser({"type": "ban", "reason": reason}, this_target)
		sendMessageToUser({"type": "ban_announce", "banned_player": this_target}, 0)

func _on_p2p_session_connect_fail(steam_id: int, _session_error: int, _state: int, debug_msg: String) -> void:
	Ui.show_system_warning("P2p session connection failed! Reason: " + debug_msg)
	remove_kitty(steam_id)

func remove_kitties() -> void:
	for cat_id: int in SteamP2P.kitties:
		kitties[cat_id].queue_free()
	kitties.clear()

func remove_kitty(pid: int = 0) -> void:
	if kitties.has(pid):
		kitties[pid].queue_free()
		kitties.erase(pid)
