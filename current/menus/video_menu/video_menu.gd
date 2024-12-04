extends Control

func _ready() -> void:
	$Width.value = get_window().size.x
	$Height.value = get_window().size.y
	$Width.value_changed.connect(_on_width_changed)
	$Height.value_changed.connect(_on_width_changed)
	$Borderless.button_pressed = get_tree().root.borderless
	$RenderingScale.value = get_window().scaling_3d_scale
	$RenderingScale.value_changed.connect(_on_rendering_scale_changed)
	$RenderingScaleLabel.text = "[center]Resolution scale: " + str($RenderingScale.value) + "[/center]" 
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


func _on_height_changed(value: float) -> void:
	Saves.set_value("settings", "height", value)

func _on_rendering_scale_changed(value: float) -> void:
	Saves.set_value("settings", "scaling_3d_scale", value)
	get_window().scaling_3d_scale = value
	$RenderingScaleLabel.text = "[center]Rendering scale: " + str($RenderingScale.value) + "[/center]" 
