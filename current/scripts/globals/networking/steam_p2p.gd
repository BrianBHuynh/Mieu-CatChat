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
	var this_requester: String = Steam.getFriendPersonaName(remote_id)
	print("%s is requesting a P2P session" % this_requester)
	Steam.acceptSessionWithUser(remote_id)
	SteamLobbies.make_p2p_handshake()

func read_p2p_packet() -> void:
	var messages: Array = Steam.receiveMessagesOnChannel(0, 100)
	if messages.size() != 0:
		#print(messages.size())
		pass
	if messages.size() > 0:
		for message: Dictionary in messages:
			if message.is_empty() or message == null:
				print("WARNING: read an empty packet with non-zero size!")
			else:
				message.payload = bytes_to_var(message.payload.decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP))
				match message["payload"]["type"]:
					"data":
						if kitties.has(message.identity):
							kitties[message.identity].global_position = Vector3(message.payload.x, message.payload.y, message.payload.z)
						else:
							var file: Resource = load("res://current/characters/mieu_peer/mieu_peer.tscn")
							var kit: Sprite3D = file.instantiate()
							get_parent().add_child(kit)
							kit.sign_adoption(message["identity"])
							kitties[message["identity"]] = kit
							print("creating")
					"ping":
						sendMessageToUser(message.identity, {"type": "pong", "send_time": message["payload"]["send_time"]})
					"pong":
						print(Steam.getPlayerNickname(message.identity) + " ping = " + str((Time.get_unix_time_from_system() - message["payload"]["send_time"])/2.0) + " seconds")

func sendMessageToUser(this_target: int, packet_data: Dictionary) -> void:
	var send_type: int = Steam.NETWORKING_SEND_RELIABLE_NO_NAGLE
	var channel: int = 0
	var this_data: PackedByteArray
	this_data.append_array(var_to_bytes(packet_data))
	this_data = this_data.compress(FileAccess.COMPRESSION_GZIP)
	if this_target == 0:
		if SteamLobbies.lobby_members.size() > 1:
			for this_member: Dictionary in SteamLobbies.lobby_members:
				if this_member['steam_id'] != SteamWorks.steam_id:
					Steam.sendMessageToUser(this_member['steam_id'], this_data, send_type, channel)
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
			for this_member: Dictionary in SteamLobbies.lobby_members:
				if this_member['steam_id'] != SteamWorks.steam_id:
					Steam.sendMessageToUser(this_member['steam_id'], this_data, send_type, channel)
	else:
		Steam.sendMessageToUser(this_target, this_data, send_type, channel)

func _on_p2p_session_connect_fail(_steam_id: int, _session_error: int, _state: int, debug_msg: String) -> void:
	print(debug_msg)
