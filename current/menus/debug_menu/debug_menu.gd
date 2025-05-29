extends Control


func _ready() -> void:
	$VBoxContainer/ScrollContainer/HBoxContainer/Networking/ChanceSlider.value = GlobalVars.chance
	$VBoxContainer/ScrollContainer/HBoxContainer/Networking/ChanceLabel.text = "Chance: 1/" + str(GlobalVars.chance)
	$VBoxContainer/ScrollContainer/HBoxContainer/Networking/GapSlider.value = GlobalVars.gap
	$VBoxContainer/ScrollContainer/HBoxContainer/Networking/GapLabel.text = "Gap: " + str(GlobalVars.gap)
	$VBoxContainer/ScrollContainer/HBoxContainer/Networking/ChanceSlider.value_changed.connect(_on_chance_changed)
	$VBoxContainer/ScrollContainer/HBoxContainer/Networking/GapSlider.value_changed.connect(_on_gap_changed)


func _on_chance_changed(value: float) -> void:
	GlobalVars.chance = int(value)
	$VBoxContainer/ScrollContainer/HBoxContainer/Networking/ChanceLabel.text = "Chance: 1/" + str(GlobalVars.chance)


func _on_gap_changed(value: float) -> void:
	GlobalVars.gap = int(value)
	$VBoxContainer/ScrollContainer/HBoxContainer/Networking/GapLabel.text = "Gap: " + str(GlobalVars.gap)


func _on_minigame_pressed() -> void:
	MinigameManager.minigame_open("minigame_template/minigame_template.tscn")


func _on_world_manager_pressed() -> void:
	Ui.show_system_debug(str(WorldManager.worlds) + str(WorldManager.current_instance_id))


func _on_debug_messages_pressed() -> void:
	if Saves.get_or_return("settings", "show_debug", false):
		Saves.set_value("settings", "show_debug", false)
	else:
		Saves.set_value("settings", "show_debug", true)
