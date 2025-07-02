extends Node


func spawn_kitty(message: Dictionary) -> void:
	while !WorldManager.middleground:
		await get_tree().process_frame
	var file: Resource = load("res://current/characters/mieu_peer/mieu_peer.tscn")
	var kit: Node2D = file.instantiate()
	WorldManager.middleground.add_child(kit)
	kit.global_position = Vector2(message.payload.x, message.payload.y)
	kit.sign_adoption(message["identity"])
	SteamP2P.kitties[message["identity"]] = kit
	Ui.show_system_debug("creating")
	kit.show()


func remove_kitties() -> void:
	for cat_id: int in SteamP2P.kitties:
		if SteamP2P.kitties[cat_id] != null and is_instance_valid(SteamP2P.kitties[cat_id]):
			SteamP2P.kitties[cat_id].remove()
	SteamP2P.kitties.clear()


func remove_kitty(pid: int = 0) -> void:
	if SteamP2P.kitties.has(pid) and SteamP2P.kitties[pid] != null:
		SteamP2P.kitties[pid].remove()
		SteamP2P.kitties.erase(pid)
