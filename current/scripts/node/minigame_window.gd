extends Window


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MinigameManager.minigame_display = self


func _on_close_requested() -> void:
	MinigameManager.close()
