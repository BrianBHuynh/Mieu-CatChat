extends Node


var mieu: Variant
var move_speed: float = 500.0
var jump_speed: float = 2.5
var frame: float = 0.016666666666
var first_world_started: bool = false
var sprite_offset: Vector2 = Vector2(0, 0)
var reset_position: Vector2
var movement_id: int = -1

func _ready() -> void:
	_load_finished()
	SignalBus.load_finished.connect(_load_finished)

func _load_finished() -> void:
	set_stretch_aspect(Saves.get_or_return("settings", "stretch_aspect", 1))
	set_window_mode(Saves.get_or_return("settings", "window_mode", 0))
	set_borderless(Saves.get_or_return("settings", "borderless", false))
	get_window().size = Vector2(Saves.get_or_return("settings", "width", DisplayServer.screen_get_size().x), Saves.get_or_add("settings", "height", DisplayServer.screen_get_size().y))

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
			#Currently there is a bug where if the window is Maximized, it will offset the cursor if window size changed
			get_window().set_mode(Window.MODE_MAXIMIZED)
		3:
			get_window().set_mode(Window.MODE_FULLSCREEN)
		4:
			get_window().set_mode(Window.MODE_EXCLUSIVE_FULLSCREEN)
	Saves.set_value("settings", "window_mode", mode)

func set_borderless(toggled: bool) -> void:
	get_window().set_flag(Window.FLAG_BORDERLESS, toggled)
	Saves.set_value("settings", "borderless", toggled)

func is_player_interactive() -> bool:
	return not (Ui.is_menu_open() or MinigameManager.minigame_display.has_focus() or Ui.chat_box.is_text_box_focused())
