extends Node


var currently_assigning: String = ""
var old_input: InputEvent
var persistant_variables: Array = ["physical_keycode", "button_index", "axis", "axis_value"]

func _unhandled_input(event: InputEvent) -> void:
	if currently_assigning != "" and InputMap.has_action(currently_assigning):
		var already_bound: bool = false
		var serialized_input: Dictionary = serialize_input(event)
		for action: String in InputMap.get_actions():
			if !action.begins_with("ui"):
				for input: InputEvent in InputMap.action_get_events(action):
					var different_event: bool = false
					for variable: String in serialized_input:
						if variable != "type" and serialized_input[variable] != input.get(variable):
							different_event = true
							break
						if variable == "physical_keycode":
							if DisplayServer.keyboard_get_label_from_physical(serialized_input[variable]) != DisplayServer.keyboard_get_label_from_physical(input.get(variable)):
								different_event = true
								break
					if not different_event:
						already_bound = true
						break
		if not already_bound:
			InputMap.action_erase_event(currently_assigning, old_input)
			InputMap.action_add_event(currently_assigning, event)
			currently_assigning = ""
			SignalBus.keybinds_updated.emit()

func save_inputs() -> void:
	var input_map: Dictionary = {}
	for action: String in InputMap.get_actions():
		if !action.begins_with("ui"):
			input_map[action] = []
			for input: InputEvent in InputMap.action_get_events(action):
				input_map[action].append(serialize_input(input))
	Saves.set_value("keybindings", "input_map", input_map)

func save_defaults() -> void:
	var input_map: Dictionary = {}
	for action: String in InputMap.get_actions():
		if !action.begins_with("ui"):
			input_map[action] = []
			for input: InputEvent in InputMap.action_get_events(action):
				input_map[action].append(serialize_input(input))
	Saves.set_value("keybindings", "defaults", input_map)

func load_inputs() -> void:
	if Saves.get_or_return("keybindings", "input_map", {}) != {}:
		for action: String in Saves.get_or_return("keybindings", "input_map", {}):
			InputMap.action_erase_events(action)
			for input: Dictionary in  Saves.get_or_return("keybindings", "input_map", {})[action]:
				InputMap.action_add_event(action, deserialize_input(input))
	else:
		save_defaults()

func reset() -> void:
	if Saves.get_or_return("keybindings", "defaults", {}) != {}:
		for action: String in Saves.get_or_return("keybindings", "defaults", {}):
			InputMap.action_erase_events(action)
			for input: Dictionary in  Saves.get_or_return("keybindings", "defaults", {})[action]:
				InputMap.action_add_event(action, deserialize_input(input))
		SignalBus.keybinds_updated.emit()

func set_assigning(action: String, input: InputEvent) -> void:
	currently_assigning = action
	old_input = input

func disarm_rebind() -> void:
	currently_assigning = ""
	old_input = InputEventKey.new()

func serialize_input(input: InputEvent, excluding: Array = []) -> Dictionary:
	var dict: Dictionary = {"type": "Error"}
	if input is InputEventKey:
		dict["type"] = "Key"
	elif input is InputEventJoypadButton:
		dict["type"] = "JoypadButton"
	elif input is InputEventJoypadMotion:
		dict["type"] = "JoypadMotion"
	for variable: Dictionary in input.get_property_list():
		if persistant_variables.has(variable.name):
			dict[variable.name] = input.get(variable.name)
	if !excluding.has(dict["type"]) and dict.get("axis_value", 1.0) != 0.0:
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
