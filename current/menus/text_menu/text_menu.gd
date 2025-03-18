extends Control
var fonts: Array = ["res://current/assets/fonts/AtkinsonHyperlegible-Regular.ttf", "res://current/assets/fonts/NotoSans-VariableFont_wdth,wght.ttf", "res://current/assets/fonts/OpenDyslexic-Regular.otf", "res://current/assets/fonts/OpenSans-VariableFont_wdth,wght.ttf", "res://current/assets/fonts/PixelifySans-VariableFont_wght.ttf", "res://current/assets/fonts/RobotoMono-VariableFont_wght.ttf"]


func _ready() -> void:
	$ScrollContainer/VBoxContainer/TextSize/TextSizeSlider.value = Saves.get_or_add("settings", "font_size", Ui.DEFAULT_FONT_SIZE)
	$ScrollContainer/VBoxContainer/TextSize/TextSizeSlider.value_changed.connect(_on_text_size_slider_value_changed)
	$ScrollContainer/VBoxContainer/ChatTextSize/TextSizeSlider.value = Saves.get_or_add("settings", "chat_font_size", Ui.DEFAULT_CHAT_FONT_SIZE)
	$ScrollContainer/VBoxContainer/ChatTextSize/TextSizeSlider.value_changed.connect(_on_chat_text_size_slider_value_changed)
	$ScrollContainer/VBoxContainer/NameTagSize/NameTagSizeSlider.value = Saves.get_or_add("settings", "name_tag_size", Ui.DEFAULT_CHAT_FONT_SIZE)
	$ScrollContainer/VBoxContainer/NameTagSize/NameTagSizeSlider.value_changed.connect(_on_name_tag_size_slider_value_changed)
	var fonts_temp: PackedStringArray = DirAccess.get_files_at("user://fonts/")
	for font: String in fonts_temp:
		fonts.append("user://fonts/" + font)

func _font_changed() -> void:
	var tempfont: String = fonts.pop_front()
	fonts.append(tempfont)
	Saves.set_value("settings", "font", tempfont)
	SignalBus.settings_updated.emit()

func _on_text_size_slider_value_changed(value: float) -> void:
	Saves.set_value("settings", "font_size", value)
	SignalBus.settings_updated.emit()

func _on_chat_text_size_slider_value_changed(value: float) -> void:
	Saves.set_value("settings", "chat_font_size", value)
	SignalBus.settings_updated.emit()

func _on_name_tag_size_slider_value_changed(value: float) -> void:
	Saves.set_value("settings", "name_tag_size", value)
	SignalBus.settings_updated.emit()
