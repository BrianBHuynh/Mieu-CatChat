extends AnimatedSprite2D

var id: int
var player_name: String


func sign_adoption(identity: int) -> void:
	id = identity
	player_name = Steam.getPlayerNickname(id)
	$RichTextLabel.text = player_name

func move_to(new_position: Vector2) -> void:
	if Saves.get_or_add("networking", "networking_tween_enabled", true):
		get_tree().create_tween().tween_property(self, "global_position", new_position, Saves.get_or_add("settings", "networking_tween_val", GlobalVars.frame*3.0))
	else:
		global_position = new_position
