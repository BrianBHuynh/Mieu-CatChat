extends Node


#This class should do what the steam_p2p class does, in almost exactly the same way, sending and recieving and so on.
#This seems simplier than the lobby implementation.


func send_message_to_user(payload: Dictionary, this_target: int = 0, send_type: int = Steam.NETWORKING_SEND_RELIABLE, channel: int = 0, encrypted: bool = false) -> void:
	Multithreading.add_task(_send_message_to_user_task.bind(payload, this_target, send_type, channel, encrypted))

func _send_message_to_user_task(payload: Dictionary, this_target: int = 0, send_type: int = Steam.NETWORKING_SEND_RELIABLE, channel: int = 0, encrypted: bool = false) -> void:
	if IpLobbies.direct_connections.size() > 1 and IpLobbies.direct_connections.has(this_target) or IpLobbies.jump_connections.has(this_target):
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
						if this_member.begins_with("Ip") and Moderation.is_allowed(this_member):
							pass#Logic to send to a user through socket.send_text, must work for sending to direct and jump connections
				_:
					for this_member: String in SteamLobbies.lobby_members:
						if this_member.begins_with("Ip") and this_member != SteamWorks.steam_id and Moderation.is_allowed(this_member):
								pass#Steam.sendMessageToUser(int(this_member), this_data, send_type, channel)
		else:
			match payload["type"]:
				"ban", "kick":
					pass
					#if SteamWorks.IntToSteamID(this_target) != SteamWorks.steam_id and SteamLobbies.is_host():
					#	Steam.sendMessageToUser(this_target, this_data, send_type, channel)
					#	await get_tree().create_timer(1).timeout
					#	Steam.closeSessionWithUser(this_target)
				_:
					pass
					#if Moderation.is_allowed(SteamWorks.IntToSteamID(this_target)):
					#	Steam.sendMessageToUser(this_target, this_data, send_type, channel)
