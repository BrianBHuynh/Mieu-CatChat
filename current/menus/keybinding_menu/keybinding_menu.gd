extends Control


var current_selected: Button

func _ready() -> void:
	populate_menu()
	SignalBus.keybinds_updated.connect(refresh_menu)

func refresh_menu() -> void:
	delete_old_keybinds()
	Multithreading.add_task(populate_menu)

func populate_menu() -> void:
	for action: String in InputMap.get_actions():
		if !action.begins_with("ui"):
			create_action(action)

func delete_old_keybinds() -> void:
	var first: bool = true
	for element: Variant in $ScrollContainer/VBoxContainer.get_children():
		if first:
			first = false
		else:
			element.queue_free()

func vbox_add_child(child: Variant) -> void:
	$ScrollContainer/VBoxContainer.add_child(child)

func create_action(action: String) -> void:
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.clip_contents = true
	hbox.add_child(create_text_label(action))
	for button: Button in create_buttons(action):
		hbox.add_child(button)
	vbox_add_child.call_deferred(hbox)

func create_text_label(action: String) -> RichTextLabel:
	var label: RichTextLabel = RichTextLabel.new()
	label.text = action
	label.set_script(load("res://current/scripts/node/rich_text_label.gd"))
	label.clip_contents = true
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_stretch_ratio = 1.0
	return label

func create_buttons(action: String) -> Array:
	var buttons: Array = []
	for input: InputEvent in InputMap.action_get_events(action):
		var button: Button = Button.new()
		var key_label: String = input.as_text().split(" ").get(0)
		if key_label == "Joypad":
			key_label = key_label + " " + input.as_text().split(" ").get(1)
		button.text = key_label
		button.set_script(load("res://current/scripts/node/button.gd"))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_stretch_ratio = .2
		button.pressed.connect(rebind_keybind.bind(action, input, button))
		buttons.append(button)
	return buttons

func rebind_keybind(action: String, input: InputEvent, button: Button) -> void:
	if current_selected != null:
		current_selected.modulate = Color(1, 1, 1, 1)
	current_selected = button
	button.modulate = Color.BLACK
	InputHandler.set_assigning(action, input)

func _on_reset_pressed() -> void:
	InputHandler.reset()

func close() -> void:
	InputHandler.disarm_rebind()
