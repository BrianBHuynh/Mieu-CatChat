extends Control


func _ready() -> void:
	$HBoxContainer/ScrollContainer/VBoxContainer/Resolution/Width.value = get_window().size.x
	$HBoxContainer/ScrollContainer/VBoxContainer/Resolution/Height.value = get_window().size.y
	
	$HBoxContainer/ScrollContainer/VBoxContainer/WindowMode.select(Saves.get_or_add("settings", "window_mode", 2))
	$HBoxContainer/ScrollContainer/VBoxContainer/WindowMode.connect("item_selected", _window_mode_changed)
	
	if Saves.get_or_add("settings", "borderless", false):
		$HBoxContainer/ScrollContainer/VBoxContainer/BorderlessBox/BorderlessLabel.text = "Toggle Borderless (True)"
	
	$HBoxContainer/ScrollContainer/VBoxContainer/Resolution/Width.value_changed.connect(_on_window_size_changed)
	$HBoxContainer/ScrollContainer/VBoxContainer/Resolution/Height.value_changed.connect(_on_window_size_changed)
	
	$HBoxContainer/ScrollContainer/VBoxContainer/BorderlessBox/Borderless.button_pressed = get_tree().root.borderless
	 
	match Saves.get_or_add("settings", "stretch_aspect", 1):
		0:
			$HBoxContainer/ScrollContainer/VBoxContainer/StretchAspect.select(0)
		1:
			$HBoxContainer/ScrollContainer/VBoxContainer/StretchAspect.select(1)
		2:
			$HBoxContainer/ScrollContainer/VBoxContainer/StretchAspect.select(2)
		3:
			$HBoxContainer/ScrollContainer/VBoxContainer/StretchAspect.select(3)
		4:
			$HBoxContainer/ScrollContainer/VBoxContainer/StretchAspect.select(4)
		_:
			pass

func _on_stretch_aspect_selected(index: int) -> void:
	GlobalVars.set_stretch_aspect(index)

func _window_mode_changed(index: int) -> void:
	GlobalVars.set_window_mode($HBoxContainer/ScrollContainer/VBoxContainer/WindowMode.get_item_id(index))

func _on_borderless_toggled(toggled_on: bool) -> void:
	GlobalVars.set_borderless(toggled_on)
	if toggled_on == false:
		$HBoxContainer/ScrollContainer/VBoxContainer/BorderlessBox/BorderlessLabel.text = "Toggle Borderless (False)"
	else:
		$HBoxContainer/ScrollContainer/VBoxContainer/BorderlessBox/BorderlessLabel.text = "Toggle Borderless (True)"

func _on_window_size_changed(value: float) -> void:
	Saves.set_value("settings", "width", value)
	get_window().size = Vector2i($HBoxContainer/ScrollContainer/VBoxContainer/Resolution/Width.value, $HBoxContainer/ScrollContainer/VBoxContainer/Resolution/Height.value) 
