extends AnimatedSprite3D

var id
var player_name

func _process(delta: float):
	print(global_position.distance_squared_to(GlobalVars.mieu.global_position))

func sign_adoption(identity: int):
	id = identity
	player_name = Steam.getPlayerNickname(id)
