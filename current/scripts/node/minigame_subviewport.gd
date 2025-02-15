extends SubViewport


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MinigameManager.minigame_subviewport = self
