extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_font()
	SignalBus.load_finished.connect(update_font)
	SignalBus.settings_updated.connect(update_font)

func update_font() -> void:
	set("theme_override_fonts/font", load(Saves.data.get_or_add("settings", {}).get_or_add("font", "res://current/assets/fonts/AtkinsonHyperlegible-Regular.ttf")))
	set("theme_override_font_sizes/font_size", Saves.data.get_or_add("settings", {}).get_or_add("font_size", 15.0))
