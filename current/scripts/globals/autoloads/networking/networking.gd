extends Node


var kitties: Dictionary = {}


func send_message_to_user(payload: Dictionary, this_target: String = "0", send_type: int = Steam.NETWORKING_SEND_RELIABLE, channel: int = 0, encrypted: bool = false) -> void:
	if this_target == "0":
		#sendtoSteamNetworking, also send to ip
		SteamNetworking.send_message_to_user(payload, UserIds.steam_id_to_id(this_target), send_type, channel, encrypted)
	elif this_target.begins_with("Steam"):
		SteamNetworking.send_message_to_user(payload, UserIds.steam_id_to_id(this_target), send_type, channel, encrypted)


func send_chat_message(message: String, this_target: String = "0", private: bool = false, channel: int = 0) -> void:
	pass


func process_message(message: Dictionary, sender: String) -> void:
	if message.is_empty() or message == null:
		Ui.show_system_debug("WARNING: read an empty packet with non-zero size!")
	elif !Moderation.is_allowed(message.identity):
		#Ui.show_system_debug("Message from blocked or banned player")
		if message.identity.begins_with("Steam"):
			Steam.closeSessionWithUser(message.identity)
		remove_kitty(message.identity)
	else:
		message.payload = bytes_to_var(message.payload.decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP))
		if message.payload is Dictionary:
			match message["payload"]["type"]:
				"data":
					MessageHandler.data(sender, message)
				"minigame_data":
					MessageHandler.minigame_data(sender, message)
				"chat":
					MessageHandler.chat(sender, message)
				"lobby_data":
					MessageHandler.lobby_data(sender, message)
				"ban":
					MessageHandler.ban(sender, message)
				"ban_announce":
					MessageHandler.ban_announce(sender, message)
				"kick":
					MessageHandler.kick(sender, message)
				"kick_announce":
					MessageHandler.kick_announce(sender, message)
				"world_info":
					MessageHandler.world_info(sender, message)
				"minigame_info":
					MessageHandler.minigame_info(sender, message)
				"encrypted_message":
					MessageHandler.encrypted_message(sender, message)
				"encrypted_key":
					MessageHandler.encrypted_key(sender, message)


func spawn_kitty(message: Dictionary) -> void:
	while !WorldManager.middleground:
		await get_tree().process_frame
	var file: Resource = load("res://current/characters/mieu_peer/mieu_peer.tscn")
	var kit: Node2D = file.instantiate()
	WorldManager.middleground.add_child(kit)
	kit.global_position = Vector2(message.payload.x, message.payload.y)
	kit.sign_adoption(message["identity"], message["name"])
	kitties[message["identity"]] = kit
	Ui.show_system_debug("creating")
	kit.show()


func remove_kitties() -> void:
	for cat_id: int in kitties:
		if kitties[cat_id] != null and is_instance_valid(kitties[cat_id]):
			kitties[cat_id].remove()
	kitties.clear()


func remove_kitty(pid: String = "0") -> void:
	if kitties.has(pid) and kitties[pid] != null:
		kitties[pid].remove()
		kitties.erase(pid)


func connected_to_multiplayer() -> bool:
	return SteamNetworking.connected_to_multiplayer() or IpNetworking.connected_to_multiplayer()
