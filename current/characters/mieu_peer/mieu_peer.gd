extends AnimatedSprite3D

var id: int
var player_name: String

func _process(_delta: float) -> void:
	pass

func sign_adoption(identity: int) -> void:
	id = identity
	player_name = Steam.getPlayerNickname(id)

func move_to(new_position: Vector3) -> void:
	if Saves.get_or_add("networking", "networking_tween_enabled", false):
		Tween.new().tween_property(self, "global_position", new_position, Saves.get_or_add("settings", "networking_tween_val", .05))
	else:
		global_position = new_position
