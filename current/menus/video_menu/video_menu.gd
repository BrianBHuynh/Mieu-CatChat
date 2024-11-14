extends Control

func _ready() -> void:
	match Saves.data.get_or_add("settings", {}).get_or_add("stretch_aspect", 1):
		0:
			$StretchAspect.select(0)
		1:
			$StretchAspect.select(1)
		2:
			$StretchAspect.select(2)
		3:
			$StretchAspect.select(3)
		4:
			$StretchAspect.select(4)
		_:
			pass


func _on_stretch_aspect_selected(index: int) -> void:
	GlobalVars.set_stretch_aspect(index)


func _window_mode_changed(index: int) -> void:
	GlobalVars.set_window_mode($WindowMode.get_item_id(index))


func _on_borderless_toggled(toggled_on: bool) -> void:
	GlobalVars.set_borderless(toggled_on)
	if toggled_on == false:
		$Borderless.text = "Toggle Borderless (False)"
	else:
		$Borderless.text = "Toggle Borderless (True)"
