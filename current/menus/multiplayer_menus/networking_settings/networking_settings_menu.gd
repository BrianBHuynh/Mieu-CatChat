extends Control


func _ready() -> void:
	$ScrollContainer/VBoxContainer/StabilityMitigation/StabilityMitigationSlider.value = Saves.get_or_return("settings", "networking_tween_val", 5.0)
	$ScrollContainer/VBoxContainer/StabilityMitigation/StabilityMitigationSlider.value_changed.connect(_on_stability_mitigation_slider_value_changed)

func _on_stability_mitigation_slider_value_changed(value: float) -> void:
	Saves.set_value("settings", "networking_tween_val", value)
