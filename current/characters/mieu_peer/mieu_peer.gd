extends Node2D


var id: int
var player_name: String

func sign_adoption(identity: int) -> void:
	id = identity
	player_name = SteamLobbies.lobby_members[id]["steam_name"]
	$MieuPeer/RichTextLabel.text = "[center]" + player_name + "[/center]"

func move_to(new_position: Vector2, sprite_position: Vector2, frame: int = -1) -> void:
	new_position = new_position.clamp(Vector2(0,0), Vector2(1920, 1080))
	if Saves.get_or_add("networking", "tween_enabled", true):
		get_tree().create_tween().tween_property(self, "global_position", new_position, GlobalVars.frame * Saves.get_or_add("networking", "tween_val", 5.0))
		get_tree().create_tween().tween_property($MieuPeer, "global_position", sprite_position, GlobalVars.frame * Saves.get_or_add("networking", "tween_val", 5.0))
	else:
		global_position = new_position
		$MieuPeer.global_position = sprite_position
	
	if frame != -1:
		$Shadow.frame = frame
		$MieuPeer.frame = frame
