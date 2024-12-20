extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_font()
	SignalBus.load_finished.connect(update_font)
	SignalBus.settings_updated.connect(update_font)

func update_font() -> void:
	var font_path: String = Saves.get_or_add("settings", "font", "res://current/assets/fonts/AtkinsonHyperlegible-Regular.ttf")
	set("theme_override_fonts/font", Helper.get_font(font_path))
	set("theme_override_font_sizes/font_size", Saves.get_or_add("settings", "font_size", Controls.DEFAULT_FONT_SIZE))
