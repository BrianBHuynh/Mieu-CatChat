extends Node
class_name Helper


static func get_font(font_path: String) -> Font:
	if ResourceLoader.exists(font_path):
		return load(font_path)
	elif (
		font_path.ends_with(".ttf")
		or font_path.ends_with(".otf")
		or font_path.ends_with(".woff")
		or font_path.ends_with(".woff2")
		or font_path.ends_with(".pfb")
		or font_path.ends_with(".pfm") 
	):
		var temp_font: FontFile = FontFile.new()
		temp_font.load_dynamic_font(Saves.get_or_add("settings", "font", "res://current/assets/fonts/AtkinsonHyperlegible-Regular.ttf"))
		return temp_font
	elif (
		font_path.ends_with(".fnt") 
		or font_path.ends_with(".font")
	):
		var temp_font: FontFile = FontFile.new()
		temp_font.load_bitmap_font(Saves.get_or_add("settings", "font", "res://current/assets/fonts/AtkinsonHyperlegible-Regular.ttf"))
		return temp_font
	else:
		Ui.show_system_warning("Invalid font format at: " + font_path)
		return load("res://current/assets/fonts/AtkinsonHyperlegible-Regular.ttf")

static func get_string_from_txt(location: String) -> String:
	return FileAccess.get_file_as_string(location)

static func dict_type_check(dict: Dictionary, key: Variant, type: String) -> bool:
	if dict.has(key) and dict[key] != null:
		return type == get_type(dict[key])
	else:
		return false

static func get_type(variable: Variant) -> String:
	return type_string(typeof(variable))
