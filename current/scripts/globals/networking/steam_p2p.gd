extends Node
const PACKET_READ_LIMIT: int = 32
var kitties: Dictionary = {}
#Currently heavily based on code from https://godotsteam.com/tutorials/p2p/

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Steam.network_messages_session_request.connect(_on_network_messages_session_request)
	Steam.network_messages_session_failed.connect(_on_p2p_session_connect_fail)
	SteamLobbies.check_command_line()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	Steam.run_callbacks()
	if SteamLobbies.lobby_id > 0:
		read_p2p_packet()

func read_all_p2p_packets(read_count: int = 0) -> void:
	if read_count < PACKET_READ_LIMIT && Steam.getAvailableP2PPacketSize(0) > 0:
		read_p2p_packet()
		read_all_p2p_packets(read_count + 1)

func _on_network_messages_session_request(remote_id: int) -> void:
	if not SteamLobbies.blocked_players.has(remote_id) or not SteamLobbies.banned_players.has(remote_id):
		var this_requester: String = Steam.getFriendPersonaName(remote_id)
		print("%s is requesting a P2P session" % this_requester)
		Steam.acceptSessionWithUser(remote_id)
		SteamLobbies.make_p2p_handshake()

func read_p2p_packet() -> void:
	var messages: Array = Steam.receiveMessagesOnChannel(0, 100)
	if messages.size() != 0:
		#print(messages.size())
		pass
	else:
		for message: Dictionary in messages:
			if message.is_empty() or message == null:
				print("WARNING: read an empty packet with non-zero size!")
			elif SteamLobbies.blocked_players.has(message.identity) or SteamLobbies.banned_players.has(message.identity):
				print("Message from blocked or banned player")
				Steam.closeSessionWithUser(message.identity)
			else:
				message.payload = bytes_to_var(message.payload.decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP))
				match message["payload"]["type"]:
					"data":
						if kitties.has(message.identity):
							kitties[message.identity].global_position = Vector3(message.payload.x, message.payload.y, message.payload.z)
						else:
							var file: Resource = load("res://current/characters/mieu_peer/mieu_peer.tscn")
							var kit: AnimatedSprite3D = file.instantiate()
							get_parent().add_child(kit)
							kit.sign_adoption(message["identity"])
							kitties[message["identity"]] = kit
							print("creating")
							kitties[message.identity].global_position = Vector3(message.payload.x, message.payload.y, message.payload.z)
					"chat":
						Controls.chat_box.process_chat_message(ChatFilter.filter(message))
					"lobby_data":
						if message.identity == Steam.getLobbyOwner(SteamLobbies.lobby_id):
							SteamLobbies.banned_players = message["payload"]["lobby_data"]["banned_players"]
							for player_id: int in SteamLobbies.banned_players:
								if SteamLobbies.lobby_members.has(player_id) or kitties.has(player_id):
									kitties[player_id].queue_free()
									kitties.erase(player_id)
									Steam.closeSessionWithUser(player_id)
									SteamLobbies.lobby_members.erase(player_id)
					"ban":
						if message.identity == Steam.getLobbyOwner(SteamLobbies.lobby_id):
							SteamLobbies.leave_lobby()
							Controls.show_system_message("You were banned from the lobby")
					"kick":
						if message.identity == Steam.getLobbyOwner(SteamLobbies.lobby_id):
							SteamLobbies.leave_lobby()
							Controls.show_system_message("You were kicked from the lobby")
							Controls.show_system_message("Reason provided: " + message["payload"][""])
					"kick_announce":
						if message.identity == Steam.getLobbyOwner(SteamLobbies.lobby_id):
							Controls.show_system_message("The lobby owner " + SteamLobbies.get_host_name() + "has kicked " + message["payload"][SteamLobbies.lobby_members["kicked_player"]])

func sendMessageToUser(this_target: int, payload: Dictionary) -> void:
	var send_type: int = Steam.NETWORKING_SEND_RELIABLE_NO_NAGLE
	var channel: int = 0
	var this_data: PackedByteArray
	this_data.append_array(var_to_bytes(payload))
	this_data = this_data.compress(FileAccess.COMPRESSION_GZIP)
	if this_target == 0:
		if SteamLobbies.lobby_members.size() > 1:
			for this_member: int in SteamLobbies.lobby_members:
				if this_member != SteamWorks.steam_id:
					Steam.sendMessageToUser(this_member, this_data, send_type, channel)
	else:
		Steam.sendMessageToUser(this_target, this_data, send_type, channel)

func sendMessageToUserFast(this_target: int, packet_data: Dictionary) -> void:
	var send_type: int = Steam.NETWORKING_SEND_URELIABLE_NO_NAGLE
	var channel: int = 0
	var this_data: PackedByteArray
	this_data.append_array(var_to_bytes(packet_data))
	this_data = this_data.compress(FileAccess.COMPRESSION_GZIP)
	if this_target == 0:
		if SteamLobbies.lobby_members.size() > 1:
			for this_member: int in SteamLobbies.lobby_members:
				if this_member != SteamWorks.steam_id:
					Steam.sendMessageToUser(this_member, this_data, send_type, channel)
	else:
		Steam.sendMessageToUser(this_target, this_data, send_type, channel)

func send_chat_message(this_target: int, message: String, private: bool) -> void:
	var send_type: int = Steam.NETWORKING_SEND_RELIABLE
	var channel: int = 0
	var this_data: PackedByteArray
	this_data.append_array(var_to_bytes({"type": "chat", "text": message, "private": private}))
	this_data = this_data.compress(FileAccess.COMPRESSION_GZIP)
	if this_target == 0:
		if SteamLobbies.lobby_members.size() > 1:
			for this_member: int in SteamLobbies.lobby_members:
				if this_member != SteamWorks.steam_id:
					Steam.sendMessageToUser(this_member, this_data, send_type, channel)
	Controls.sent_chat_message(message, private, this_target)

func send_lobby_data(this_target: int) -> void:
	if SteamLobbies.is_host():
		var send_type: int = Steam.NETWORKING_SEND_RELIABLE
		var channel: int = 0
		var this_data: PackedByteArray
		this_data.append_array(var_to_bytes({"type": "lobby_data", "lobby_data": {"banned_players": SteamLobbies.banned_players}}))
		this_data = this_data.compress(FileAccess.COMPRESSION_GZIP)
		if this_target == 0:
			if SteamLobbies.lobby_members.size() > 1:
				for this_member: int in SteamLobbies.lobby_members:
					if this_member != SteamWorks.steam_id:
						if not SteamLobbies.banned_players.has(this_member):
							Steam.sendMessageToUser(this_member, this_data, send_type, channel)
						else:
							this_data.clear()
							this_data.append_array(var_to_bytes({"type": "ban", "reason": "No reason provided"}))
							Steam.sendMessageToUser(this_member, this_data, send_type, channel)

func send_kick(this_target: int, reason: String) -> void:
	if SteamLobbies.is_host():
		var this_data: PackedByteArray
		this_data.append_array(var_to_bytes({"type": "kick", "reason": reason}))
		sendMessageToUser(this_target, {"type": "kick_announce", "kicked_player": this_target})

func _on_p2p_session_connect_fail(_steam_id: int, _session_error: int, _state: int, debug_msg: String) -> void:
	print(debug_msg)
