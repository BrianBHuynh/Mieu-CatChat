extends Node


var kitties: Dictionary = {}
#Currently code improved on from https://godotsteam.com/tutorials/p2p/

func _ready() -> void:
	Steam.network_messages_session_request.connect(_on_network_messages_session_request)
	Steam.network_messages_session_failed.connect(_on_p2p_session_connect_fail)
	SteamLobbies.check_command_line()

func _process(_delta: float) -> void:
	Steam.run_callbacks()
	if SteamLobbies.lobby_id > 0:
		read_p2p_messages()

func _on_network_messages_session_request(remote_id: int) -> void:
	if Moderation.is_allowed(remote_id):
		var this_requester: String = Steam.getFriendPersonaName(remote_id)
		Ui.show_system_message(this_requester + " is requesting a P2P session")
		Steam.acceptSessionWithUser(remote_id)
		WorldsTracker.send_world(remote_id)
		SteamLobbies.make_p2p_handshake()

func read_p2p_messages() -> void:
	var messages: Array = Steam.receiveMessagesOnChannel(0, 1000)
	if messages.size() == 0:
		pass
	else:
		for message: Dictionary in messages:
			if message.is_empty() or message == null:
				print("WARNING: read an empty packet with non-zero size!")
			elif !Moderation.is_allowed(message.identity):
				print("Message from blocked or banned player")
				Steam.closeSessionWithUser(message.identity)
				remove_kitty(message.identity)
			else:
				message.payload = bytes_to_var(message.payload.decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP))
				match message["payload"]["type"]:
					"data":
						if kitties.has(message.identity):
							if WorldsTracker.has(WorldsTracker.current_world, message.identity) and WorldsTracker.dimensions == message.payload["dimensions"]:
								if message.payload["dimensions"] == 3 and kitties[message.identity] is AnimatedSprite3D:
									kitties[message.identity].move_to(Vector3(message.payload.x, message.payload.y, message.payload.z))
								elif message.payload["dimensions"] == 2 and kitties[message.identity] is AnimatedSprite2D:
									kitties[message.identity].move_to(Vector2(message.payload.x, message.payload.y))
								else:
									Ui.show_system_message("Error reading locational data")
									remove_kitty(message.identity)
							else:
								remove_kitty(message.identity)
						elif WorldsTracker.has(WorldsTracker.current_world, message.identity):
							if WorldsTracker.dimensions == 3 and message.payload["dimensions"] == 3 and get_tree().current_scene is Node3D:
								var file: Resource = load("res://current/characters/3D/mieu_peer/mieu_peer.tscn")
								var kit: AnimatedSprite3D = file.instantiate()
								get_parent().add_child(kit)
								kit.sign_adoption(message["identity"])
								kitties[message["identity"]] = kit
								Ui.show_system_message("creating", Color.GREEN)
								kitties[message.identity].global_position = Vector3(message.payload.x, message.payload.y, message.payload.z)
							elif WorldsTracker.dimensions == 2 and message.payload["dimensions"] == 2 and get_tree().current_scene is Node2D:
								while !WorldsTracker.middleground:
									await get_tree().process_frame
								var file: Resource = load("res://current/characters/2D/mieu_peer/mieu_peer.tscn")
								var kit: AnimatedSprite2D = file.instantiate()
								WorldsTracker.middleground.add_child(kit)
								kit.sign_adoption(message["identity"])
								kitties[message["identity"]] = kit
								Ui.show_system_message("creating", Color.GREEN)
								kitties[message.identity].global_position = Vector2(message.payload.x, message.payload.y)
					"chat":
						Ui.process_chat_message(ChatFilter.filter(message))
					"lobby_data":
						if message.identity == Steam.getLobbyOwner(SteamLobbies.lobby_id):
							Moderation.banned_players = message["payload"]["lobby_data"]["banned_players"]
							for player_id: int in Moderation.banned_players:
								if SteamLobbies.lobby_members.has(player_id) or kitties.has(player_id):
									remove_kitty(player_id)
									Steam.closeSessionWithUser(player_id)
									SteamLobbies.lobby_members.erase(player_id)
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

func sendMessageToUser(payload: Dictionary, this_target: int = 0) -> void:
	if SteamLobbies.lobby_members.size() > 1:
		var send_type: int = Steam.NETWORKING_SEND_RELIABLE
		var channel: int = 0
		var this_data: PackedByteArray
		this_data.append_array(var_to_bytes(payload))
		this_data = this_data.compress(FileAccess.COMPRESSION_GZIP)
		if this_target == 0:
			for this_member: int in SteamLobbies.lobby_members:
				if this_member != SteamWorks.steam_id and Moderation.is_allowed(this_member):
					Steam.sendMessageToUser(this_member, this_data, send_type, channel)
		else:
			if Moderation.is_allowed(this_target):
				Steam.sendMessageToUser(this_target, this_data, send_type, channel)

func sendMessageToUserFast(packet_data: Dictionary, this_target: int = 0) -> void:
	if SteamLobbies.lobby_members.size() > 1:
		var send_type: int = Steam.NETWORKING_SEND_URELIABLE_NO_NAGLE
		var channel: int = 0
		var this_data: PackedByteArray
		this_data.append_array(var_to_bytes(packet_data))
		this_data = this_data.compress(FileAccess.COMPRESSION_GZIP)
		if this_target == 0:
			if packet_data["type"] == "data":
				for this_member: int in SteamLobbies.lobby_members:
					if this_member != SteamWorks.steam_id and WorldsTracker.has(WorldsTracker.current_world, this_member) and Moderation.is_allowed(this_member):
						Steam.sendMessageToUser(this_member, this_data, send_type, channel)
			else:
				for this_member: int in SteamLobbies.lobby_members:
					if this_member != SteamWorks.steam_id and Moderation.is_allowed(this_member):
						Steam.sendMessageToUser(this_member, this_data, send_type, channel)
		else:
			if Moderation.is_allowed(this_target):
				Steam.sendMessageToUser(this_target, this_data, send_type, channel)

func send_chat_message(message: String, this_target: int = 0, private: bool = false) -> void:
	if SteamLobbies.lobby_members.size() > 1:
		var send_type: int = Steam.NETWORKING_SEND_RELIABLE
		var channel: int = 0
		var this_data: PackedByteArray
		this_data.append_array(var_to_bytes({"type": "chat", "text": message, "private": private}))
		this_data = this_data.compress(FileAccess.COMPRESSION_GZIP)
		if this_target == 0:
			for this_member: int in SteamLobbies.lobby_members:
				if this_member != SteamWorks.steam_id and Moderation.is_allowed(this_member):
					Steam.sendMessageToUser(this_member, this_data, send_type, channel)
			Ui.sent_chat_message(message, private, this_target)
		else:
			if Moderation.is_allowed(this_target):
				Steam.sendMessageToUser(this_target, this_data, send_type, channel)
				Ui.sent_chat_message(message, private, this_target)
			else:
				Ui.show_system_warning("Target is either blocked or banned!")
	else:
		Ui.sent_chat_message(message, private, this_target)

func send_lobby_data(this_target: int = 0, reason: String = "No reason provided") -> void:
	if SteamLobbies.is_host() and SteamLobbies.lobby_members.size() > 1:
		var send_type: int = Steam.NETWORKING_SEND_RELIABLE
		var channel: int = 0
		var this_data: PackedByteArray
		this_data.append_array(var_to_bytes({"type": "lobby_data", "lobby_data": {"banned_players": Moderation.banned_players}}))
		this_data = this_data.compress(FileAccess.COMPRESSION_GZIP)
		if this_target == 0:
			for this_member: int in SteamLobbies.lobby_members:
				if this_member != SteamWorks.steam_id:
					if Moderation.is_allowed(this_member):
						Steam.sendMessageToUser(this_member, this_data, send_type, channel)
					else:
						var ban_message: PackedByteArray = var_to_bytes({"type": "ban", "reason": reason})
						Steam.sendMessageToUser(this_member, ban_message, send_type, channel)
		else:
			if this_target != SteamWorks.steam_id:
				if not Moderation.is_allowed(this_target):
					Steam.sendMessageToUser(this_target, this_data, send_type, channel)
				else:
					var ban_message: PackedByteArray = var_to_bytes({"type": "ban", "reason": reason})
					Steam.sendMessageToUser(this_target, ban_message, send_type, channel)

func send_kick(reason: String = "no reason provided", this_target: int = 0) -> void:
	if SteamLobbies.is_host() and SteamLobbies.lobby_members.size() > 1:
		sendMessageToUser({"type": "kick", "reason": reason}, this_target)
		sendMessageToUser({"type": "kick_announce", "kicked_player": this_target}, 0)

func send_ban(reason: String = "no reason provided", this_target: int = 0) -> void:
	if SteamLobbies.is_host() and SteamLobbies.lobby_members.size() > 1:
		sendMessageToUser({"type": "ban", "reason": reason}, this_target)
		sendMessageToUser({"type": "kick_announce", "banned_player": this_target}, 0)

func _on_p2p_session_connect_fail(_steam_id: int, _session_error: int, _state: int, debug_msg: String) -> void:
	#Ui.show_system_message("P2p session connection failed! Reason: " + debug_msg)
	print("P2p session connection failed! Reason: " + debug_msg)

func remove_kitties() -> void:
	for cat_id: int in SteamP2P.kitties:
		kitties[cat_id].queue_free()
	kitties.clear()

func remove_kitty(pid: int = 0) -> void:
	if kitties.has(pid):
		kitties[pid].queue_free()
		kitties.erase(pid)
