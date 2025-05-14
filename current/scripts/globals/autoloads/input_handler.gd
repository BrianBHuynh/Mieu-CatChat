extends Node


var currently_assigning: String = ""

func save_inputs() -> void:
	var input_map: Dictionary = {}
	for action: String in InputMap.get_actions():
		if !action.begins_with("ui"):
			input_map[action] = []
			for input: InputEvent in InputMap.action_get_events(action):
				input_map[action].append(serialize_input(input))
	Saves.set_value("keybindings", "input_map", input_map)

func load_inputs() -> void:
	if Saves.get_or_return("keybindings", "input_map", {}) != {}:
		for action: String in Saves.get_or_return("keybindings", "input_map", {}):
			InputMap.action_erase_events(action)
			for input: Dictionary in  Saves.get_or_return("keybindings", "input_map", {})[action]:
				InputMap.action_add_event(action, deserialize_input(input))

func _unhandled_input(event: InputEvent) -> void:
	if currently_assigning != "" and InputMap.has_action(currently_assigning):
		var serialized_input: Dictionary = serialize_input(event)
		var deserialized_input: InputEvent = deserialize_input(serialized_input)
		if deserialized_input != null:
			InputMap.action_add_event(currently_assigning, deserialized_input)
			currently_assigning = ""
			SignalBus.keybinds_updated.emit()

func set_assigning(action: String) -> void:
	currently_assigning = action

func serialize_input(input: InputEvent, excluding: Array = []) -> Dictionary:
	var dict: Dictionary = {}
	if input is InputEventKey:
		dict["type"] = "Key"
	elif input is InputEventJoypadButton:
		dict["type"] = "JoypadButton"
	elif input is InputEventJoypadMotion:
		dict["type"] = "JoypadMotion"
	for variable: Dictionary in input.get_property_list():
		dict[variable.name] = input.get(variable.name)
	if !excluding.has(dict["type"]):
		return dict
	else:
		return {}

func deserialize_input(dict: Dictionary) -> InputEvent:
	var input: InputEvent
	if dict.has("type"):
		match dict["type"]:
			"Key":
				input = InputEventKey.new()
			"JoypadButton":
				input = InputEventJoypadButton.new()
			"JoypadMotion":
				input = InputEventJoypadMotion.new()
		for variable: String in dict:
			input.set(variable, dict[variable])
	return input
