extends Control

func _ready() -> void:
	$Width.value = get_window().size.x
	$Height.value = get_window().size.y
	$Width.value_changed.connect(_on_width_changed)
	$Height.value_changed.connect(_on_width_changed)
	$Borderless.button_pressed = get_tree().root.borderless
	$ResolutionScale.value = get_window().scaling_3d_scale
	$ResolutionScale.value_changed.connect(_on_resolutionscale_changed)
	$ResolutionScaleLabel.text = "[center]Resolution scale: " + str($ResolutionScale.value) + "[/center]" 
	match Saves.get_or_add("settings", "stretch_aspect", 1):
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


func _on_width_changed(value: float) -> void:
	Saves.set_value("settings", "width", value)
	get_window().size = Vector2(Saves.get_or_add("settings", "width", 1920), Saves.get_or_add("settings", "height", 1080))


func _on_height_changed(value: float) -> void:
	Saves.set_value("settings", "height", value)
	get_window().size = Vector2(Saves.get_or_add("settings", "width", 1920), Saves.get_or_add("settings", "height", 1080))

func _on_resolutionscale_changed(value: float) -> void:
	Saves.set_value("settings", "scaling_3d_scale", value)
	get_window().scaling_3d_scale = value
	print(get_window().scaling_3d_scale)
	$ResolutionScaleLabel.text = "[center]Resolution scale: " + str($ResolutionScale.value) + "[/center]" 
