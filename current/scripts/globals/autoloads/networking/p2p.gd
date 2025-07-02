extends Node


var kitties: Dictionary = {}


func send_message_to_user(payload: Dictionary, this_target: int = 0, send_type: int = Steam.NETWORKING_SEND_RELIABLE, channel: int = 0, encrypted: bool = false) -> void:
	pass


func send_chat_message(message: String, this_target: int = 0, private: bool = false, channel: int = 0) -> void:
	pass


func send_lobby_data(this_target: int = 0, _reason: String = "No reason provided", channel: int = 0) -> void:
	pass


func spawn_kitty(message: Dictionary) -> void:
	while !WorldManager.middleground:
		await get_tree().process_frame
	var file: Resource = load("res://current/characters/mieu_peer/mieu_peer.tscn")
	var kit: Node2D = file.instantiate()
	WorldManager.middleground.add_child(kit)
	kit.global_position = Vector2(message.payload.x, message.payload.y)
	kit.sign_adoption(message["identity"])
	kitties[message["identity"]] = kit
	Ui.show_system_debug("creating")
	kit.show()


func remove_kitties() -> void:
	for cat_id: int in kitties:
		if kitties[cat_id] != null and is_instance_valid(kitties[cat_id]):
			kitties[cat_id].remove()
	kitties.clear()


func remove_kitty(pid: int = 0) -> void:
	if kitties.has(pid) and kitties[pid] != null:
		kitties[pid].remove()
		kitties.erase(pid)
