extends Node

func _ready() -> void:
	SignalBus.load_finished.connect(initialize)

func _process(_delta: float) -> void:
	pass

func initialize() -> void:
	Status.init_stat("food", 100.0, -0.0011574074, 100.0, 0.0)

func feed(satiety: float) -> void:
	Status.change_stat("food", satiety)

func get_current_food() -> float:
	return Status.get_stat("food")
