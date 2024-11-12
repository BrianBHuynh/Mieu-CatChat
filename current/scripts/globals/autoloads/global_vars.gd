extends Node

var mieu: CharacterBody3D

func _ready() -> void:
	SignalBus.load_finished.connect(load_finished)

func load_finished() -> void:
	set_stretch_aspect(Saves.data.get_or_add("settings", {}).get_or_add("stretch_aspect", 1))

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
