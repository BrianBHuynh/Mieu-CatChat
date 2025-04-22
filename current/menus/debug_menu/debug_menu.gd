extends Control


func _ready() -> void:
	$VBoxContainer/ScrollContainer/HBoxContainer/Networking/ChanceSlider.value = NetworkingData.chance
	$VBoxContainer/ScrollContainer/HBoxContainer/Networking/ChanceLabel.text = "Chance: 1/" + str(NetworkingData.chance)
	$VBoxContainer/ScrollContainer/HBoxContainer/Networking/GapSlider.value = NetworkingData.gap
	$VBoxContainer/ScrollContainer/HBoxContainer/Networking/GapLabel.text = "Gap: " + str(NetworkingData.gap)

func _on_chance_changed(value: float) -> void:
	NetworkingData.chance = int(value)
	$VBoxContainer/ScrollContainer/HBoxContainer/Networking/ChanceLabel.text = "Chance: 1/" + str(NetworkingData.chance)

func _on_gap_changed(value: float) -> void:
	NetworkingData.gap = int(value)
	$VBoxContainer/ScrollContainer/HBoxContainer/Networking/GapLabel.text = "Gap: " + str(NetworkingData.gap)

func _on_minigame_pressed() -> void:
	MinigameManager.minigame_open("minigame_template/minigame_template.tscn")

func _on_world_manager_pressed() -> void:
	Ui.show_system_debug(str(WorldManager.worlds) + str(WorldManager.current_instance_id))

func _on_debug_messages_pressed() -> void:
	if Saves.get_or_return("settings", "show_debug", false):
		Saves.set_value("settings", "show_debug", false)
	else:
		Saves.set_value("settings", "show_debug", true)
