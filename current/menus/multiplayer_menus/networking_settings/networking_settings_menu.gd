extends Control


func _ready() -> void:
	$ScrollContainer/VBoxContainer/StabilityMitigation/StabilityMitigationSlider.value = Saves.get_or_return("networking", "tween_val", 5.0)
	$ScrollContainer/VBoxContainer/StabilityMitigation2/AutoTweenCheckBox.button_pressed = Saves.get_or_return("networking", "auto_tween_enabled", true)
	$ScrollContainer/VBoxContainer/StabilityMitigation/StabilityMitigationSlider.value_changed.connect(_on_stability_mitigation_slider_value_changed)
	$ScrollContainer/VBoxContainer/StabilityMitigation2/AutoTweenCheckBox.toggled.connect(_on_auto_tween_check_box_toggled)
	$ScrollContainer/VBoxContainer/StabilityMitigation/RichTextLabel.text = "[center]Network Stability Mitigation:" + str(Saves.get_or_return("networking", "tween_val", 5.0)) + "[/center]"

func _on_stability_mitigation_slider_value_changed(value: float) -> void:
	Saves.set_value("networking", "tween_val", value)
	if value == 0.0:
		Saves.set_value("networking", "manual_tween_enabled", false)
	else:
		Saves.set_value("networking", "manual_tween_enabled", true)
	$ScrollContainer/VBoxContainer/StabilityMitigation/RichTextLabel.text = "[center]Network Stability Mitigation:" + str(value) + "[/center]"

func _on_auto_tween_check_box_toggled(toggled_on: bool) -> void:
	Saves.set_value("networking", "auto_tween_enabled", toggled_on)
