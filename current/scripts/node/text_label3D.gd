extends Label3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_font()
	SignalBus.load_finished.connect(update_font)
	SignalBus.settings_updated.connect(update_font)


func update_font():
	await get_tree().create_timer(1.0/60.0).timeout
	var font_path: String = Saves.get_or_add("settings", "font", "res://current/assets/fonts/AtkinsonHyperlegible-Regular.ttf")
	font = load(font_path)
	font_size = Saves.get_or_add("settings", "font_size", Controls.DEFAULT_FONT_SIZE)
