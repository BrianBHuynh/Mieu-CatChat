extends RichTextLabel


func _ready() -> void:
	update_font()
	SignalBus.load_finished.connect(update_font)
	SignalBus.settings_updated.connect(update_font)
	add_theme_constant_override("outline_size", 5)
	add_theme_constant_override("shadow_outline_size", 3)
	if Saves.get_or_return("settings", "invert_outline", false):
		add_theme_color_override("font_outline_color", get_theme_color("default_color").inverted())
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

func update_font() -> void:
	var font_path: String = Saves.get_or_return("settings", "font", "res://current/assets/fonts/AtkinsonHyperlegible-Regular.ttf")
	set("theme_override_fonts/normal_font", Helper.get_font(font_path))
	set("theme_override_font_sizes/normal_font_size", Saves.get_or_return("settings", "font_size", Ui.DEFAULT_FONT_SIZE))
	if Saves.get_or_return("settings", "invert_outline", false):
		add_theme_color_override("font_outline_color", get_theme_color("default_color").inverted())
	else:
		add_theme_color_override("font_outline_color", Color.BLACK)
