extends Node

func _process(_delta: float) -> void:
	SignalBus.load_finished.connect(initialize)

func initialize() -> void:
	Status.init_stat("food", 100.0, -0.0011574074, 100.0, 0.0)

func feed(satiety: float) -> void:
	Status.change_stat("food", satiety)

func get_current_food() -> float:
	return Status.get_stat("food")
