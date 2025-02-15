extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = get_viewport_rect().size / 2
	hide()
	MinigameManager.minigame_display = self
