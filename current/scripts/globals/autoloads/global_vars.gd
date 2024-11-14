extends Node

var mieu: CharacterBody3D

func _ready() -> void:
	SignalBus.load_finished.connect(load_finished)

func load_finished() -> void:
	set_stretch_aspect(Saves.data.get_or_add("settings", {}).get_or_add("stretch_aspect", 1))
	set_window_mode(Saves.data.get_or_add("settings", {}).get_or_add("window_mode", 2))
	set_borderless(Saves.data.get_or_add("settings", {}).get_or_add("borderless", false))

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
	Saves.data.get_or_add("settings", {})["stretch_aspect"] = aspect

func set_window_mode(mode: int) -> void:
	match mode:
		0: 
			get_tree().root.mode = Window.MODE_WINDOWED
		2:
			get_tree().root.mode = Window.MODE_MAXIMIZED
		3:
			get_tree().root.mode = Window.MODE_FULLSCREEN
		4:
			get_tree().root.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	Saves.data.get_or_add("settings", {})["window_mode"] = mode

func set_borderless(toggled: bool) -> void:
	get_tree().root.borderless = toggled
	Saves.data.get_or_add("settings", {})["borderless"] = toggled
