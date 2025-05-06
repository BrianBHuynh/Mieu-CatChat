extends Node


var currently_assigning: String = ""

func _unhandled_input(event: InputEvent) -> void:
	if currently_assigning != "" and InputMap.has_action(currently_assigning):
		var temp: Dictionary = serialize_input(event)
		InputMap.action_add_event(currently_assigning, deserialize_input(temp))
		currently_assigning = ""
		SignalBus.keybinds_updated.emit()

func set_assigning(action: String) -> void:
	currently_assigning = action

func serialize_input(input: InputEvent) -> Dictionary:
	var dict: Dictionary = {}
	if input is InputEventKey:
		dict["type"] = "key"
		dict["keycode"] = input.keycode
		dict["key_label"] = input.key_label
		dict["location"] = input.location
		dict["physical_keycode"] = input.physical_keycode
		dict["unicode"] = input.unicode
		dict["alt_pressed"] = input.alt_pressed
		dict["ctrl_pressed"] = input.ctrl_pressed
		dict["ctrl_pressed"] = input.meta_pressed
		dict["shift_pressed"] = input.shift_pressed
		dict["device"] = input.device
	return dict

func deserialize_input(dict: Dictionary) -> InputEvent:
	var input: InputEvent
	if dict["type"] == "key":
		input = InputEventKey.new()
		input.keycode = dict["keycode"]
		input.key_label = dict["key_label"]
		input.location = dict["location"]
		input.physical_keycode = dict["physical_keycode"]
		input.unicode = dict["unicode"]
		input.alt_pressed = dict["alt_pressed"]
		input.ctrl_pressed = dict["ctrl_pressed"]
		input.meta_pressed = dict["ctrl_pressed"]
		input.shift_pressed = dict["shift_pressed"]
		input.device = dict["device"]
	return input
