extends Window


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MinigameManager.minigame_display = self
	close_requested.connect(MinigameManager.minigame_close)
	focus_exited.connect(pause)
	focus_entered.connect(play)

func pause() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

func play() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
