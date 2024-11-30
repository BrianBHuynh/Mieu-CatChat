extends Node
class_name Status

func get_stat(name: String) -> float:
	var cur_stat: float = Saves.get_value("status", name, 100.0)
	var time_changed: float = Saves.get_value("status", name + "_time", Time.get_unix_time_from_system())
	var rate_of_change: float = Saves.get_value("status", name + "_rate", 1.0)
	var max: float = Saves.get_value("status", name + "_max", 100.0)
	var min: float = Saves.get_value("status", name + "_min", 0.0)
	cur_stat = cur_stat + (get_time_difference_minutes(time_changed)*rate_of_change)
	if cur_stat <= min:
		Saves.set_value("vpet", name, min)
		Saves.set_value("vpet", name + "_time", Time.get_unix_time_from_system())
		return min
	elif cur_stat >= max:
		Saves.set_value("vpet", name, max)
		Saves.set_value("vpet", name + "_time", Time.get_unix_time_from_system())
		return max
	else:
		return cur_stat

func set_stat(name: String, value: float) -> float:
	var max: float = Saves.get_value("status", name + "_max", 100.0)
	var min: float = Saves.get_value("status", name + "_min", 0.0)
	if value <= min:
		Saves.set_value("vpet", name, min)
		Saves.set_value("vpet", name + "_time", Time.get_unix_time_from_system())
		return min
	elif value >= max:
		Saves.set_value("vpet", name, max)
		Saves.set_value("vpet", name + "_time", Time.get_unix_time_from_system())
		return max
	else:
		Saves.set_value("vpet", name, value)
		Saves.set_value("vpet", name + "_time", Time.get_unix_time_from_system())
		return value

func change_stat(name: String, change: float) -> float:
	var cur_stat = get_stat(name)
	return set_stat(name, cur_stat + change)

func param_exist(name: String, param: String) -> bool:
	return Saves.has("vpet", name + "_" + param)

func get_param(name: String, param: String) -> bool:
	if param_exist(name, param):
		return Saves.get_value("vpet", name + "_" + param,  0.0)
	else:
		return 0.0

func set_param(name: String, param: String, value: float):
	Saves.set_value("vpet", name + "_" + param, value)

func get_time_difference_seconds(time: float) -> float:
	return Time.get_unix_time_from_system() - time

func get_time_difference_minutes(time: float) -> float:
	return (Time.get_unix_time_from_system() - time)/60.0
