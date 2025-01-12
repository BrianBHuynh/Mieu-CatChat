extends Camera3D
var mode: bool = false


func _ready() -> void:
	fov = Saves.get_or_return("settings", "fov", 80.0)
	SignalBus.load_finished.connect(load_finished)

func load_finished() -> void:
	fov = Saves.get_or_return("settings", "fov", 80.0)
