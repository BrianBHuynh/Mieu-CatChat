extends Node2D


var id: int
var player_name: String
var since_last_frame: float = 0.0

func _physics_process(_delta: float) -> void:
	since_last_frame = since_last_frame + 1
	if Saves.get_or_return("settings", "show_debug", false) and Saves.get_or_return("networking", "auto_tween_enabled", true):
		$MieuPeer/RichTextLabel.text = "[center]" + player_name + "[/center]\n Networking tween value: " + str(Saves.get_or_add("networking", "tween_val", 5.0) + " + " + str(StabilityMitigator.get_mitigation(id)))

func sign_adoption(identity: int) -> void:
	id = identity
	player_name = SteamLobbies.lobby_members[id]["steam_name"]
	$MieuPeer/RichTextLabel.text = "[center]" + player_name + "[/center]"

func move_to(new_position: Vector2, sprite_y: float, movement_id: int, frame: int = -1) -> void:
	new_position = new_position.clamp(Vector2(0,0), Vector2(1920, 1080))
	StabilityMitigator.add_mitigation_data(id, movement_id, since_last_frame)
	if Saves.get_or_add("networking", "manual_tween_enabled", true):
		if Saves.get_or_add("networking", "auto_tween_enabled", true):
			get_tree().create_tween().tween_property(self, "global_position", new_position, GlobalVars.frame * (Saves.get_or_add("networking", "tween_val", 5.0) + StabilityMitigator.get_mitigation(id)))
			get_tree().create_tween().tween_property($MieuPeer, "position", Vector2($MieuPeer.position.x, sprite_y), GlobalVars.frame * (Saves.get_or_add("networking", "tween_val", 5.0) + StabilityMitigator.get_mitigation(id)))
		else:
			get_tree().create_tween().tween_property(self, "global_position", new_position, GlobalVars.frame * (Saves.get_or_add("networking", "tween_val", 5.0)))
			get_tree().create_tween().tween_property($MieuPeer, "position", Vector2($MieuPeer.position.x, sprite_y), GlobalVars.frame * (Saves.get_or_add("networking", "tween_val", 5.0)))
	else:
		if Saves.get_or_add("networking", "auto_tween_enabled", true):
			get_tree().create_tween().tween_property(self, "global_position", new_position, GlobalVars.frame * StabilityMitigator.get_mitigation(id))
			get_tree().create_tween().tween_property($MieuPeer, "position", Vector2($MieuPeer.position.x, sprite_y), GlobalVars.frame * StabilityMitigator.get_mitigation(id))
		else:
			global_position = new_position
			$MieuPeer.global_position = sprite_y
	
	if $MieuPeer.position.y <= GlobalVars.sprite_offset.y:
		$Shadow.scale = Vector2(.5, .25) * (($MieuPeer.position.y - GlobalVars.sprite_offset.y)/300.0 + 1)
	elif $Shadow.scale != Vector2(.5, .25):
		$Shadow.scale = Vector2(.5, .25)
	
	if frame != -1:
		set_frame(frame)
	
	since_last_frame = 0

func set_frame(frame: int) -> void:
	$Shadow.frame = frame
	$MieuPeer.frame = frame
