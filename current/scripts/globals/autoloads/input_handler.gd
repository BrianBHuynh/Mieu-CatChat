extends Node


var currently_assigning: String = ""

func _unhandled_input(event: InputEvent) -> void:
	if currently_assigning != "" and InputMap.has_action(currently_assigning):
		InputMap.action_add_event(currently_assigning, event)
		currently_assigning = ""
		SignalBus.keybinds_updated.emit()

func set_assigning(action: String) -> void:
	currently_assigning = action
