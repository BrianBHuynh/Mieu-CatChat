extends Control
var filtered_words: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for words in Saves.get_or_add("networking", "chat_filter", {}):
		var hbox: HBoxContainer = HBoxContainer.new()
		hbox.clip_contents = true
		
		var FilteredText: TextEdit = TextEdit.new()
		FilteredText.placeholder_text = "Filtered word here"
		hbox.add_child(FilteredText)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_save_filter_button_pressed() -> void:
	pass # Replace with function body.
