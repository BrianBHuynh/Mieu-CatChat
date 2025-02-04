extends Control


func _ready() -> void:
	load_finished()
	SignalBus.load_finished.connect(load_finished)

func load_finished() -> void:
	$FoodBar.max_value = Status.get_param("food", "max")
	$FoodBar.min_value = Status.get_param("food", "min")
	$FoodBar.value = Status.get_stat("food")

func _process(_delta: float) -> void:
	$FoodBar.value = Status.get_stat("food")


func _on_feed_button_pressed() -> void:
	Status.change_stat("food", 20)
