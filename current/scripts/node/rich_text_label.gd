extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_font()
	SignalBus.load_finished.connect(update_font)
	SignalBus.settings_updated.connect(update_font)

func update_font() -> void:
	#Bug workaround, remove await once https://github.com/godotengine/godot/issues/98819 is solved
	await get_tree().create_timer(1.0/60.0).timeout
	set("theme_override_fonts/normal_font", load(Saves.data.get_or_add("settings", {}).get_or_add("font", "res://fonts/AtkinsonHyperlegible-Regular.ttf")))
	set("theme_override_font_sizes/normal_font_size", Saves.data.get_or_add("settings", {}).get_or_add("font_size", 15.0))
