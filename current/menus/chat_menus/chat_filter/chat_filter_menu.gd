extends Control
var filtered_words: Dictionary = Saves.get_or_add("networking", "chat_filter", {})

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var new_hbox: HBoxContainer = HBoxContainer.new()
	new_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	new_hbox.clip_contents = true
	
	var new_FilteredText: TextEdit = TextEdit.new()
	new_FilteredText.placeholder_text = "Filtered word here"
	new_FilteredText.clip_contents = true
	new_FilteredText.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_FilteredText.size_flags_stretch_ratio = 1.0
	new_hbox.add_child(new_FilteredText)
	
	var new_ReplacementText: TextEdit = TextEdit.new()
	new_ReplacementText.placeholder_text = "Word to replace it with"
	new_ReplacementText.clip_contents = true
	new_ReplacementText.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_ReplacementText.size_flags_stretch_ratio = 1.0
	new_hbox.add_child(new_ReplacementText)
	
	var new_BanUser: CheckBox = CheckBox.new()
	new_BanUser.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_BanUser.size_flags_stretch_ratio = .2
	new_hbox.add_child(new_BanUser)
	
	var new_BlockUser: CheckBox = CheckBox.new()
	new_BlockUser.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_BlockUser.size_flags_stretch_ratio = .2
	new_hbox.add_child(new_BlockUser)
	
	var new_KickUser: CheckBox = CheckBox.new()
	new_KickUser.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_KickUser.size_flags_stretch_ratio = .2
	new_hbox.add_child(new_KickUser)
	
	var new_DeleteMessage: CheckBox = CheckBox.new()
	new_DeleteMessage.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_DeleteMessage.size_flags_stretch_ratio = .2
	new_hbox.add_child(new_DeleteMessage)
	
	$ScrollContainer/VBoxContainer.add_child(new_hbox)
	print(filtered_words)
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_save_filter_button_pressed() -> void:
	filtered_words.clear()
	var first = true
	for Hbox in $ScrollContainer/VBoxContainer.get_children():
		if first:
			first = false
		else:
			var Fields = Hbox.get_children()
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
