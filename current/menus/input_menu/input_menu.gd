extends Control


func _ready() -> void:
	$ScrollContainer/VBoxContainer/Mouse_senseitivity/Mouse_Sense_Slider.value = Saves.get_or_add("settings", "mouse_sense", .25)

func _on_mouse_sense_slider_value_changed(value: float) -> void:
	Saves.set_value("settings", "mouse_sense", value)
