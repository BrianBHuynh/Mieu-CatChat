extends Camera2D


@export var following: bool = false
@export var camera_zoom: float = 1.0

func _ready() -> void:
	zoom = Vector2(camera_zoom, camera_zoom)

func _process(_delta: float) -> void:
	if following:
		global_position = GlobalVars.mieu.global_position-Vector2(0.0, 65.0)
	else:
		global_position = Vector2(960.0, 540.0)
