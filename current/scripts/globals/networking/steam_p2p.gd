extends Node
const PACKET_READ_LIMIT: int = 32
#Currently heavily based on code from https://godotsteam.com/tutorials/p2p/

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Steam.connect("p2p_session_request", _on_p2p_session_request)
	Steam.connect("p2p_session_connect_fail", _on_p2p_session_connect_fail)
	Steamlobbies.check_command_line()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	Steam.run_callbacks()
	if Steamlobbies.lobby_id > 0:
		read_p2p_packet()

func read_all_p2p_packets(read_count: int = 0) -> void:
	if read_count < PACKET_READ_LIMIT && Steam.getAvailableP2PPacketSize(0) > 0:
		read_p2p_packet()
		read_all_p2p_packets(read_count + 1)

func _on_p2p_session_request(remote_id: int) -> void:
	var this_requester: String = Steam.getFriendPersonaName(remote_id)
	print("%s is requesting a P2P session" % this_requester)
	Steam.acceptP2PSessionWithUser(remote_id)
	Steamlobbies.make_p2p_handshake()

func read_p2p_packet() -> void:
	var packet_size: int = Steam.getAvailableP2PPacketSize(0)
	if packet_size > 0:
		var this_packet: Dictionary = Steam.readP2PPacket(packet_size, 0)
		if this_packet.is_empty() or this_packet == null:
			print("WARNING: read an empty packet with non-zero size!")
		var _packet_sender: int = this_packet['remote_steam_id']
		var packet_code: PackedByteArray = this_packet['data']
		var readable_data: Dictionary = bytes_to_var(packet_code)
		print("Packet: %s" % readable_data)

func send_p2p_packet(this_target: int, packet_data: Dictionary) -> void:
	var send_type: int = Steam.P2P_SEND_RELIABLE
	var channel: int = 0
	var this_data: PackedByteArray
	this_data.append_array(var_to_bytes(packet_data))
	if this_target == 0:
		if Steamlobbies.lobby_members.size() > 1:
			for this_member in Steamlobbies.lobby_members:
				if this_member['steam_id'] != Steamworks.steam_id:
					Steam.sendP2PPacket(this_member['steam_id'], this_data, send_type, channel)
	else:
		Steam.sendP2PPacket(this_target, this_data, send_type, channel)

func _on_p2p_session_connect_fail(steam_id: int, session_error: int) -> void:
	match session_error:
		0:
			print("WARNING: Session failure with %s: no error given" % steam_id)
		1:
			print("WARNING: Session failure with %s: target user not running the same game" % steam_id)
		2:
			print("WARNING: Session failure with %s: local user doesn't own app / game" % steam_id)
		3:
			print("WARNING: Session failure with %s: target user isn't connected to Steam" % steam_id)
		4:
			print("WARNING: Session failure with %s: connection timed out" % steam_id)
		5:
			print("WARNING: Session failure with %s: unused" % steam_id)
		_:
			print("WARNING: Session failure with %s: unknown error %s" % [steam_id, session_error])
