extends Node2D


var id: int
var player_name: String

func sign_adoption(identity: int) -> void:
	id = identity
	player_name = SteamLobbies.lobby_members[id]["steam_name"]
	$RichTextLabel.text = "[center]" + player_name + "[/center]"

func move_to(new_position: Vector2) -> void:
	new_position = new_position.clamp(Vector2(0,0), Vector2(1920, 1080))
	if Saves.get_or_add("networking", "networking_tween_enabled", true):
		get_tree().create_tween().tween_property(self, "global_position", new_position, Saves.get_or_add("settings", "networking_tween_val", GlobalVars.frame*5.0))
	else:
		global_position = new_position
