extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	populate_from_file()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_save_filter_button_pressed() -> void:
	var filtered_words: Dictionary = {}
	var first: bool = true
	for Hbox: HBoxContainer in $ScrollContainer/VBoxContainer.get_children():
		if first:
			first = false
		else:
			var Fields: Array = Hbox.get_children()
			var FilteredText: String = Fields.pop_front().text
			if not FilteredText.is_empty():
				var new_dict: Dictionary = {}
				new_dict["replacement_word"] = Fields.pop_front().text
				new_dict["ban"] = Fields.pop_front().button_pressed
				new_dict["block"] = Fields.pop_front().button_pressed
				new_dict["kick"] = Fields.pop_front().button_pressed
				new_dict["delete"] = Fields.pop_front().button_pressed
				filtered_words[FilteredText] = new_dict
	Saves.set_value("networking", "chat_filter", filtered_words)
	print(Saves.get_or_add("networking", "chat_filter", {}))

func create_empty_entry() -> void:
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.clip_contents = true
	
	hbox.add_child(create_blank_text_edit("Filtered word here", ""))
	hbox.add_child(create_blank_text_edit("Word to replace it with", ""))
	hbox.add_child(create_blank_check_button())
	hbox.add_child(create_blank_check_button())
	hbox.add_child(create_blank_check_button())
	hbox.add_child(create_blank_check_button())
	
	$ScrollContainer/VBoxContainer.add_child(hbox)
	$ScrollContainer/VBoxContainer.move_child(hbox, 1)

func populate_from_file() -> void:
	var filtered_words: Dictionary = Saves.get_or_add("networking", "chat_filter", {})
	for word: String in filtered_words:
		var hbox: HBoxContainer = HBoxContainer.new()
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.clip_contents = true

		hbox.add_child(create_blank_text_edit("", word))
		hbox.add_child(create_text_edit(word, "replacement_word", filtered_words))
		hbox.add_child(create_check_button(word, "ban", filtered_words))
		hbox.add_child(create_check_button(word, "block", filtered_words))
		hbox.add_child(create_check_button(word, "kick", filtered_words))
		hbox.add_child(create_check_button(word, "delete", filtered_words))
		
		$ScrollContainer/VBoxContainer.add_child(hbox)

func clear_entries() -> void:
	var first: bool = true
	for hbox: HBoxContainer in $ScrollContainer/VBoxContainer.get_children():
		if first:
			first = false
		else:
			hbox.queue_free()

func _on_add_entry_pressed() -> void:
	create_empty_entry()

func create_text_edit(word: String, key: String, filter: Dictionary) -> TextEdit:
	var text_edit: TextEdit = TextEdit.new()
	text_edit.text = filter[word][key]
	text_edit.clip_contents = true
	text_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_edit.size_flags_stretch_ratio = 1.0
	return text_edit

func create_check_button(word: String, key: String, filter: Dictionary) -> Button:
	var button: CheckBox = CheckBox.new()
	button.button_pressed = filter[word][key]
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_stretch_ratio = .2
	return button

func create_blank_check_button() -> Button:
	var button: CheckBox = CheckBox.new()
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_stretch_ratio = .2
	return button

func create_blank_text_edit(placeholder_text: String, text: String) -> TextEdit:
	var text_edit: TextEdit = TextEdit.new()
	text_edit.placeholder_text = placeholder_text
	text_edit.text = text
	text_edit.clip_contents = true
	text_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_edit.size_flags_stretch_ratio = 1.0
	return text_edit
