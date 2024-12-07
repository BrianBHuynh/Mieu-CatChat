extends AnimatedSprite3D

var id
var player_name

func _process(delta: float):
	pass

func sign_adoption(identity: int):
	id = identity
	player_name = Steam.getPlayerNickname(id)

func move_to(new_position: Vector3):
	if Saves.get_or_add("settings", "networking_tween", false):
		Tween.new().tween_property(self, "global_position", new_position, Saves.get_or_add("settings", "networking_tween_val", .05))
	else:
		global_position = new_position
