extends Control
var camera3D: Camera3D
var fonts: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera3D = get_viewport().get_camera_3d()
	$Fov_Slider.value = camera3D.fov
	$Text_Size_Slider.value = Saves.data.get_or_add("settings", {}).get_or_add("font_size", 15.0)
	fonts = Array(DirAccess.get_files_at("res://fonts/"))


func _on_fov_slider_value_changed(value: float) -> void:
	camera3D.fov = value
	Saves.set_value("settings", "fov", value)

func _font_changed() -> void:
	var tempfont: String = fonts.pop_front()
	if tempfont.ends_with(".import"):
		tempfont = fonts.pop_front()
	fonts.append(tempfont)
	Saves.set_value("settings", "font", "fonts/" + tempfont)
	SignalBus.settings_updated.emit()

func _on_text_size_slider_value_changed(value: float) -> void:
	Saves.set_value("settings", "font_size", value)
	SignalBus.settings_updated.emit()
