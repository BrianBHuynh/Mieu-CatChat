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
	
	var FilteredText: TextEdit = TextEdit.new()
	FilteredText.placeholder_text = "Filtered word here"
	FilteredText.clip_contents = true
	FilteredText.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	FilteredText.size_flags_stretch_ratio = 1.0
	hbox.add_child(FilteredText)
	
	var ReplacementText: TextEdit = TextEdit.new()
	ReplacementText.placeholder_text = "Word to replace it with"
	ReplacementText.clip_contents = true
	ReplacementText.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ReplacementText.size_flags_stretch_ratio = 1.0
	hbox.add_child(ReplacementText)
	
	var BanUser: CheckBox = CheckBox.new()
	BanUser.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	BanUser.size_flags_stretch_ratio = .2
	hbox.add_child(BanUser)
	
	var BlockUser: CheckBox = CheckBox.new()
	BlockUser.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	BlockUser.size_flags_stretch_ratio = .2
	hbox.add_child(BlockUser)
	
	var KickUser: CheckBox = CheckBox.new()
	KickUser.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	KickUser.size_flags_stretch_ratio = .2
	hbox.add_child(KickUser)
	
	var DeleteMessage: CheckBox = CheckBox.new()
	DeleteMessage.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	DeleteMessage.size_flags_stretch_ratio = .2
	hbox.add_child(DeleteMessage)
	
	$ScrollContainer/VBoxContainer.add_child(hbox)
	$ScrollContainer/VBoxContainer.move_child(hbox, 1)

func populate_from_file() -> void:
	var filtered_words: Dictionary = Saves.get_or_add("networking", "chat_filter", {})
	for word: String in filtered_words:
		var hbox: HBoxContainer = HBoxContainer.new()
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.clip_contents = true
		
		var FilteredText: TextEdit = TextEdit.new()
		FilteredText.placeholder_text = "Filtered word here"
		FilteredText.text = word
		FilteredText.clip_contents = true
		FilteredText.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		FilteredText.size_flags_stretch_ratio = 1.0
		hbox.add_child(FilteredText)
		
		var ReplacementText: TextEdit = TextEdit.new()
		ReplacementText.placeholder_text = "Word to replace it with"
		ReplacementText.text = filtered_words[word]["replacement_word"]
		ReplacementText.clip_contents = true
		ReplacementText.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		ReplacementText.size_flags_stretch_ratio = 1.0
		hbox.add_child(ReplacementText)
		
		var BanUser: CheckBox = CheckBox.new()
		BanUser.button_pressed = filtered_words[word]["ban"]
		BanUser.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		BanUser.size_flags_stretch_ratio = .2
		hbox.add_child(BanUser)
		
		var BlockUser: CheckBox = CheckBox.new()
		BlockUser.button_pressed = filtered_words[word]["block"]
		BlockUser.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		BlockUser.size_flags_stretch_ratio = .2
		hbox.add_child(BlockUser)
		
		var KickUser: CheckBox = CheckBox.new()
		KickUser.button_pressed = filtered_words[word]["kick"]
		KickUser.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		KickUser.size_flags_stretch_ratio = .2
		hbox.add_child(KickUser)
		
		var DeleteMessage: CheckBox = CheckBox.new()
		DeleteMessage.button_pressed = filtered_words[word]["delete"]
		DeleteMessage.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		DeleteMessage.size_flags_stretch_ratio = .2
		hbox.add_child(DeleteMessage)
		
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
