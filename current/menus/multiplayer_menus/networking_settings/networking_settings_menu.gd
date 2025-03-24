extends Control


func _ready() -> void:
	$ScrollContainer/VBoxContainer/StabilityMitigation/StabilityMitigationSlider.value = Saves.get_or_return("settings", "networking_tween_val", 5.0)
	$ScrollContainer/VBoxContainer/StabilityMitigation/StabilityMitigationSlider.value_changed.connect(_on_stability_mitigation_slider_value_changed)
	$ScrollContainer/VBoxContainer/StabilityMitigation/RichTextLabel.text = "[center]Network Stability Mitigation:" + Saves.get_or_return("settings", "networking_tween_val", 5.0) + "[/center]"

func _on_stability_mitigation_slider_value_changed(value: float) -> void:
	Saves.set_value("networking", "tween_val", value)
	if value == 0.0:
		Saves.set_value("networking", "tween_enabled", false)
	else:
		Saves.set_value("networking", "tween_enabled", true)
	$ScrollContainer/VBoxContainer/StabilityMitigation/RichTextLabel.text = "[center]Network Stability Mitigation:" + str(value) + "[/center]"
