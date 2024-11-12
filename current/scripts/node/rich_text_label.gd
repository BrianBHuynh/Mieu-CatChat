extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_font()
	SignalBus.load_finished.connect(update_font)
	SignalBus.settings_updated.connect(update_font)

func update_font() -> void:
	#Bug workaround, remove await once https://github.com/godotengine/godot/issues/98819 is solved
	await get_tree().create_timer(1.0/60.0).timeout
	var font_path: String = Saves.data.get_or_add("settings", {}).get_or_add("font", "res://fonts/AtkinsonHyperlegible-Regular.ttf")
	if ResourceLoader.exists(font_path):
		set("theme_override_fonts/normal_font", load(font_path))
	elif (
		font_path.ends_with(".ttf")
		or font_path.ends_with(".otf")
		or font_path.ends_with(".woff")
		or font_path.ends_with(".woff2")
		or font_path.ends_with(".pfb")
		or font_path.ends_with(".pfm") 
	):
		var temp_font: FontFile = FontFile.new()
		temp_font.load_dynamic_font(Saves.data.get_or_add("settings", {}).get_or_add("font", "res://current/assets/fonts/AtkinsonHyperlegible-Regular.ttf"))
		set("theme_override_fonts/normal_font", temp_font)
	elif (
		font_path.ends_with(".fnt") 
		or font_path.ends_with(".font")
	):
		var temp_font: FontFile = FontFile.new()
		temp_font.load_bitmap_font(Saves.data.get_or_add("settings", {}).get_or_add("font", "res://current/assets/fonts/AtkinsonHyperlegible-Regular.ttf"))
		set("theme_override_fonts/normal_font", temp_font)
	else:
		push_warning("Invalid font format!")
	
	set("theme_override_font_sizes/normal_font_size", Saves.data.get_or_add("settings", {}).get_or_add("font_size", 15.0))
