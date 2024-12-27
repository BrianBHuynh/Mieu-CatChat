extends Camera3D
var mode: bool = false


func _ready() -> void:
	fov = Saves.get_or_add("settings", "fov", 80.0)


func _process(_delta: float) -> void:
	pass
