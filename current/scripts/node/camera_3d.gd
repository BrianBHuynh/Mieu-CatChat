extends Camera3D
var mode: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fov = Saves.get_value("settings", "fov", 80.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
