extends Node

func _process(_delta: float) -> void:
	pass

func feed() -> void:
	Saves.set_value("vpet", "food", get_current_food() + 50.0)
	Saves.set_value("vpet", "food_time", Time.get_unix_time_from_system())

func get_current_food() -> float:
	var curfood: float = Saves.get_or_add("vpet", "food", 100.0)
	var time_fed: float = Saves.get_or_add("vpet", "food_time", Time.get_unix_time_from_system())
	curfood = Saves.get_or_add("vpet", "food", 100.0) - (get_time_difference(time_fed)/Saves.get_or_add("vpet", "food_difficulty", 60.0))
	if curfood <= 0.0:
		Saves.set_value("vpet", "food", 100.0)
		Saves.set_value("vpet", "time_fed", Time.get_unix_time_from_system())
		return 0.0
	return curfood

func get_time_difference(time: float) -> float:
	return Time.get_unix_time_from_system() - time
