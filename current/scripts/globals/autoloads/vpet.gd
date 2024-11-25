extends Node

func _process(_delta: float) -> void:
	print(get_current_food())

func feed() -> void:
	Saves.add_data("vpet", "food", get_current_food() + 50.0)
	Saves.add_data("vpet", "time_fed", Time.get_unix_time_from_system())

func get_current_food() -> float:
	var curfood: float = Saves.get_value("vpet", "food", 100.0)
	var time_fed: float = Saves.get_value("vpet", "time_fed", Time.get_unix_time_from_system())
	curfood = Saves.get_value("vpet", "food", 100.0) - (get_time_difference(time_fed)/Saves.get_value("vpet", "food_difficulty", 60.0))
	if curfood <= 0.0:
		return 0.0
	return curfood

func get_time_difference(time: float) -> float:
	return Time.get_unix_time_from_system() - time
