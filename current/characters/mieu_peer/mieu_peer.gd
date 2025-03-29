extends Node2D


var id: int
var player_name: String

func sign_adoption(identity: int) -> void:
	id = identity
	player_name = SteamLobbies.lobby_members[id]["steam_name"]
	$MieuPeer/RichTextLabel.text = "[center]" + player_name + "[/center]"

func move_to(new_position: Vector2, sprite_y: float, frame: int = -1) -> void:
	new_position = new_position.clamp(Vector2(0,0), Vector2(1920, 1080))
	if Saves.get_or_add("networking", "tween_enabled", true):
		get_tree().create_tween().tween_property(self, "global_position", new_position, GlobalVars.frame * Saves.get_or_add("networking", "tween_val", 5.0))
		get_tree().create_tween().tween_property($MieuPeer, "global_position.y", sprite_y, GlobalVars.frame * Saves.get_or_add("networking", "tween_val", 5.0))
	else:
		global_position = new_position
		$MieuPeer.global_position.y = sprite_y
	
	if $MieuPeer.position.y <= GlobalVars.sprite_offset.y:
		$Shadow.scale = Vector2(.5, .25) * (($MieuPeer.position.y - GlobalVars.sprite_offset.y)/300.0 + 1)
	elif $Shadow.scale != Vector2(.5, .25):
		$Shadow.scale = Vector2(.5, .25)
	
	if frame != -1:
		set_frame(frame)

func set_frame(frame: int) -> void:
	$Shadow.frame = frame
	$MieuPeer.frame = frame
