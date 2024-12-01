extends Control
var camera3D: Camera3D
var fonts: Array = ["res://current/assets/fonts/AtkinsonHyperlegible-Regular.ttf", "res://current/assets/fonts/NotoSans-VariableFont_wdth,wght.ttf", "res://current/assets/fonts/OpenDyslexic-Regular.otf", "res://current/assets/fonts/OpenSans-VariableFont_wdth,wght.ttf", "res://current/assets/fonts/PixelifySans-VariableFont_wght.ttf", "res://current/assets/fonts/RobotoMono-VariableFont_wght.ttf"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera3D = get_viewport().get_camera_3d()
	$Fov_Slider.value = camera3D.fov
	$Text_Size_Slider.value = Saves.get_or_add("settings", "font_size", 15.0)
	$Text_Size_Slider.value_changed.connect(_on_text_size_slider_value_changed)
	var fonts_temp: PackedStringArray = DirAccess.get_files_at("user://fonts/")
	for font: String in fonts_temp:
		fonts.append("user://fonts/" + font)


func _on_fov_slider_value_changed(value: float) -> void:
	camera3D.fov = value
	Saves.set_value("settings", "fov", value)

func _font_changed() -> void:
	var tempfont: String = fonts.pop_front()
	fonts.append(tempfont)
	Saves.set_value("settings", "font", tempfont)
	SignalBus.settings_updated.emit()

func _on_text_size_slider_value_changed(value: float) -> void:
	Saves.set_value("settings", "font_size", value)
	SignalBus.settings_updated.emit()
