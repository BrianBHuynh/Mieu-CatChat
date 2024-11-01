extends Control
var camera3D: Camera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera3D = get_viewport().get_camera_3d()
	$Fov_Slider.value = camera3D.fov


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_fov_slider_value_changed(value: float) -> void:
	camera3D.fov = value
