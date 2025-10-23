extends Node


func _ready() -> void:
	Steam.network_messages_session_request.connect(_on_network_messages_session_request)
	Steam.network_messages_session_failed.connect(_on_p2p_session_connect_fail)


func process(_delta: float) -> void:
	if SteamLobbies.lobby_id > 0:
		read_p2p_messages()


func _on_network_messages_session_request(remote_id: int) -> void:
	if Moderation.is_allowed(SteamNetworking.IntTOSteamID(remote_id)):
		Steam.acceptSessionWithUser(remote_id)
		WorldManager.send_world(SteamNetworking.IntToSteamID(remote_id))
		send_message_to_user({"type": "handshake"}, remote_id)


func read_p2p_messages() -> void:
	var messages: Array = Steam.receiveMessagesOnChannel(0, 1000)
	if messages.size() != 0:
		for message: Dictionary in messages:
			Networking.process_message(message, message.identity)


func send_message_to_user(payload: Dictionary, this_target: int = 0, send_type: int = Steam.NETWORKING_SEND_RELIABLE, channel: int = 0, encrypted: bool = false) -> void:
	Multithreading.add_task(_send_message_to_user_task.bind(payload, this_target, send_type, channel, encrypted))


func _send_message_to_user_task(payload: Dictionary, this_target: int = 0, send_type: int = Steam.NETWORKING_SEND_RELIABLE, channel: int = 0, encrypted: bool = false) -> void:
	if SteamNetworking.connected_to_multiplayer():
		var this_data: PackedByteArray
		if encrypted:
			this_data.append_array(Cryptography.encrypted_messages_sent[Cryptography.encode_payload(payload)]["payload"])
		else:
			this_data.append_array(var_to_bytes(payload))
		
		this_data = this_data.compress(FileAccess.COMPRESSION_GZIP)
		if this_target == 0:
			match payload["type"]:
				"data":
					for this_member: String in WorldManager.get_same_world():
						if this_member.begins_with("Steam") and Moderation.is_allowed(this_member):
							Steam.sendMessageToUser(int(this_member), this_data, send_type, channel)
				_:
					for this_member: String in SteamLobbies.lobby_members:
						if this_member.begins_with("Steam") and this_member != SteamNetworking.steam_id and Moderation.is_allowed(this_member):
								Steam.sendMessageToUser(int(this_member), this_data, send_type, channel)
		else:
			match payload["type"]:
				"ban", "kick":
					if SteamNetworking.IntToSteamID(this_target) != SteamNetworking.steam_id and SteamLobbies.is_host():
						Steam.sendMessageToUser(this_target, this_data, send_type, channel)
						await get_tree().create_timer(1).timeout
						Steam.closeSessionWithUser(this_target)
				_:
					if Moderation.is_allowed(SteamNetworking.IntToSteamID(this_target)):
						Steam.sendMessageToUser(this_target, this_data, send_type, channel)


func send_chat_message(message: String, this_target: int = 0, private: bool = false, channel: int = 0) -> void:
	Multithreading.add_task(_send_chat_message_task.bind(message, int(this_target), private, channel))


func _send_chat_message_task(message: String, this_target: int = 0, private: bool = false, channel: int = 0) -> void:
	if SteamNetworking.connected_to_multiplayer():
		var send_type: int = Steam.NETWORKING_SEND_RELIABLE
		var this_data: PackedByteArray
		this_data.append_array(var_to_bytes({"type": "chat", "text": message, "private": private}))
		this_data = this_data.compress(FileAccess.COMPRESSION_GZIP)
		if this_target == 0:
			for this_member: String in SteamLobbies.lobby_members:
				if this_member != SteamNetworking.steam_id and Moderation.is_allowed(this_member):
					Steam.sendMessageToUser(int(this_member), this_data, send_type, channel)
		else:
			if Moderation.is_allowed(SteamNetworking.IntToSteamID(this_target)):
				Steam.sendMessageToUser(this_target, this_data, send_type, channel)
			else:
				Ui.show_system_warning("Target is either blocked or banned!")
	Ui.sent_chat_message.call_deferred(message, this_target, private)


func send_lobby_data(this_target: int = 0, _reason: String = "No reason provided", channel: int = 0) -> void:
	Multithreading.add_task(_send_lobby_data_task.bind(this_target, _reason, channel))


func _send_lobby_data_task(this_target: int = 0, _reason: String = "No reason provided", channel: int = 0) -> void:
	if SteamLobbies.is_host() and SteamNetworking.connected_to_multiplayer():
		var send_type: int = Steam.NETWORKING_SEND_RELIABLE
		var this_data: PackedByteArray
		this_data.append_array(var_to_bytes({"type": "lobby_data", "lobby_data": {"banned_players": Moderation.banned_players}}))
		this_data = this_data.compress(FileAccess.COMPRESSION_GZIP)
		if this_target == 0:
			for this_member: String in SteamLobbies.lobby_members:
				if this_member.begins_with("Steam") and this_member != SteamNetworking.steam_id and Moderation.is_allowed(this_member):
					Steam.sendMessageToUser(int(this_member), this_data, send_type, channel)
		else:
			if SteamNetworking.IntToSteamID(this_target) != SteamNetworking.steam_id and Moderation.is_allowed(SteamNetworking.IntToSteamID(this_target)):
					Steam.sendMessageToUser(this_target, this_data, send_type, channel)


func send_kick(this_target: int = 0, reason: String = "no reason provided") -> void:
	if SteamLobbies.is_host() and SteamNetworking.connected_to_multiplayer():
		send_message_to_user({"type": "kick", "reason": reason}, this_target)
		send_message_to_user({"type": "kick_announce", "kicked_player": this_target}, 0)


func send_ban(this_target: int = 0, reason: String = "no reason provided") -> void:
	if SteamLobbies.is_host() and SteamNetworking.connected_to_multiplayer():
		send_message_to_user({"type": "ban", "reason": reason}, this_target)
		send_message_to_user({"type": "ban_announce", "banned_player": this_target}, 0)


func _on_p2p_session_connect_fail(steam_id: int, _session_error: int, _state: int, debug_msg: String) -> void:
	Ui.show_system_warning("P2P session connection failed! Reason: " + debug_msg)
	Networking.remove_kitty(SteamNetworking.IntToSteamID(steam_id))
