extends Node

var mieu: CharacterBody3D

func _ready() -> void:
	SignalBus.load_finished.connect(load_finished)

func load_finished() -> void:
	set_stretch_aspect(Saves.get_or_add("settings", "stretch_aspect", 1))
	set_window_mode(Saves.get_or_add("settings", "window_mode", 2))
	set_borderless(Saves.get_or_add("settings", "borderless", false))
	get_window().scaling_3d_scale = Saves.get_or_add("settings", "scaling_3d_scale", 1.0)
	get_window().size = Vector2(Saves.get_or_add("settings", "width", 1920), Saves.get_or_add("settings", "height", 1080))

func set_resolution(width: int, height: int) -> void:
	Saves.set_value("settings", "width", width)
	Saves.set_value("settings", "height", height)
	Window.size = Vector2(width, height)

func set_stretch_aspect(aspect: int) -> void:
	match aspect:
		0:
			get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_IGNORE
		1:
			get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
		2:
			get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP_WIDTH
		3:
			get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP_HEIGHT
		4:
			get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	Saves.set_value("settings", "stretch_aspect", aspect)

func set_window_mode(mode: int) -> void:
	match mode:
		0: 
			get_window().set_mode(Window.MODE_WINDOWED)
		1:
			get_window().set_mode(Window.MODE_MINIMIZED)
		2:
			get_window().set_mode(Window.MODE_MAXIMIZED)
		3:
			get_window().set_mode(Window.MODE_FULLSCREEN)
		4:
			get_window().set_mode(Window.MODE_EXCLUSIVE_FULLSCREEN)
	Saves.set_value("settings", "window_mode", mode)

func set_borderless(toggled: bool) -> void:
	get_window().set_flag(Window.FLAG_BORDERLESS, toggled)
	Saves.set_value("settings", "borderless", toggled)
