extends Node


func _ready() -> void:
	Steam.network_messages_session_request.connect(_on_network_messages_session_request)
	Steam.network_messages_session_failed.connect(_on_p2p_session_connect_fail)


func process(_delta: float) -> void:
	if SteamLobbies.lobby_id > 0:
		read_p2p_messages()


func _on_network_messages_session_request(remote_id: int) -> void:
	if Moderation.is_allowed(remote_id):
		Steam.acceptSessionWithUser(remote_id)
		WorldManager.send_world(remote_id)
		P2P.send_message_to_user({"type": "handshake"}, remote_id)


func read_p2p_messages() -> void:
	var messages: Array = Steam.receiveMessagesOnChannel(0, 1000)
	if messages.size() != 0:
		for message: Dictionary in messages:
			process_message(message)


func process_message(message: Dictionary) -> void:
	if message.is_empty() or message == null:
		Ui.show_system_debug("WARNING: read an empty packet with non-zero size!")
	elif !Moderation.is_allowed(message.identity):
		Ui.show_system_debug("Message from blocked or banned player")
		Steam.closeSessionWithUser(message.identity)
		P2P.remove_kitty(message.identity)
	else:
		message.payload = bytes_to_var(message.payload.decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP))
		if message.payload is Dictionary:
			match message["payload"]["type"]:
				"data":
					MessageHandler.data(message)
				"minigame_data":
					MessageHandler.minigame_data(message)
				"chat":
					MessageHandler.chat(message)
				"lobby_data":
					MessageHandler.lobby_data(message)
				"ban":
					MessageHandler.ban(message)
				"ban_announce":
					MessageHandler.ban_announce(message)
				"kick":
					MessageHandler.kick(message)
				"kick_announce":
					MessageHandler.kick_announce(message)
				"world_info":
					MessageHandler.world_info(message)
				"minigame_info":
					MessageHandler.minigame_info(message)
				"encrypted_message":
					MessageHandler.encrypted_message(message)
				"encrypted_key":
					MessageHandler.encrypted_key(message)


func send_message_to_user(payload: Dictionary, this_target: int = 0, send_type: int = Steam.NETWORKING_SEND_RELIABLE, channel: int = 0, encrypted: bool = false) -> void:
	Multithreading.add_task(_send_message_to_user_task.bind(payload, this_target, send_type, channel, encrypted))


func _send_message_to_user_task(payload: Dictionary, this_target: int = 0, send_type: int = Steam.NETWORKING_SEND_RELIABLE, channel: int = 0, encrypted: bool = false) -> void:
	if SteamLobbies.lobby_members.size() > 1:
		var this_data: PackedByteArray
		if encrypted:
			this_data.append_array(Cryptography.encrypted_messages_sent[Cryptography.encode_payload(payload)]["payload"])
		else:
			this_data.append_array(var_to_bytes(payload))
		
		this_data = this_data.compress(FileAccess.COMPRESSION_GZIP)
		if this_target == 0:
			match payload["type"]:
				"data":
					for this_member: int in WorldManager.get_same_world():
						if Moderation.is_allowed(this_member):
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
	Multithreading.add_task(_send_chat_message_task.bind(message, this_target, private, channel))


func _send_chat_message_task(message: String, this_target: int = 0, private: bool = false, channel: int = 0) -> void:
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
	Ui.sent_chat_message.call_deferred(message, this_target, private)


func send_lobby_data(this_target: int = 0, _reason: String = "No reason provided", channel: int = 0) -> void:
	Multithreading.add_task(_send_lobby_data_task.bind(this_target, _reason, channel))


func _send_lobby_data_task(this_target: int = 0, _reason: String = "No reason provided", channel: int = 0) -> void:
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
		send_message_to_user({"type": "kick", "reason": reason}, this_target)
		send_message_to_user({"type": "kick_announce", "kicked_player": this_target}, 0)


func send_ban(this_target: int = 0, reason: String = "no reason provided") -> void:
	if SteamLobbies.is_host() and SteamLobbies.lobby_members.size() > 1:
		send_message_to_user({"type": "ban", "reason": reason}, this_target)
		send_message_to_user({"type": "ban_announce", "banned_player": this_target}, 0)


func _on_p2p_session_connect_fail(steam_id: int, _session_error: int, _state: int, debug_msg: String) -> void:
	Ui.show_system_warning("P2p session connection failed! Reason: " + debug_msg)
	P2P.remove_kitty(steam_id)
