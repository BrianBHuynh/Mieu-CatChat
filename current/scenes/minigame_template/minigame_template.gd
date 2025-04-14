extends Node2D


func _on_button_pressed() -> void:
	$Button.text = "you win!"

func accept_minigame_data(_message: Dictionary) -> void:
	pass
