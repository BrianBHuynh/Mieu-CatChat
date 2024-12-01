extends Node
class_name Status

static func init_stat(stat_name: String, stat_value: float, stat_rate: float, stat_max: float, stat_min: float) -> void:
	Saves.get_or_add("status", stat_name, stat_value)
	Saves.get_or_add("status", stat_name + "_rate", stat_rate)
	Saves.get_or_add("status", stat_name + "_max", stat_max)
	Saves.get_or_add("status", stat_name + "_min", stat_min)
	Saves.get_or_add("status", stat_name + "_time", Time.get_unix_time_from_system())

static func get_stat(stat_name: String) -> float:
	var cur_stat: float = Saves.get_or_add("status", stat_name, 100.0)
	var time_changed: float = Saves.get_or_add("status", stat_name + "_time", Time.get_unix_time_from_system())
	var rate_of_change: float = Saves.get_or_add("status", stat_name + "_rate", 1.0)
	var val_max: float = Saves.get_or_add("status", stat_name + "_max", 100.0)
	var val_min: float = Saves.get_or_add("status", stat_name + "_min", 0.0)
	cur_stat = cur_stat + (get_time_difference_minutes(time_changed)*rate_of_change)
	if cur_stat <= val_min:
		Saves.set_value("vpet", stat_name, val_min)
		Saves.set_value("vpet", stat_name + "_time", Time.get_unix_time_from_system())
		return val_min
	elif cur_stat >= val_max:
		Saves.set_value("vpet", stat_name, val_max)
		Saves.set_value("vpet", stat_name + "_time", Time.get_unix_time_from_system())
		return val_max
	else:
		return cur_stat

static func set_stat(stat_name: String, value: float) -> float:
	var val_max: float = Saves.get_or_add("status", stat_name + "_max", 100.0)
	var val_min: float = Saves.get_or_add("status", stat_name + "_min", 0.0)
	if value <= val_min:
		Saves.set_value("vpet", stat_name, val_min)
		Saves.set_value("vpet", stat_name + "_time", Time.get_unix_time_from_system())
		return val_min
	elif value >= val_max:
		Saves.set_value("vpet", stat_name, val_max)
		Saves.set_value("vpet", stat_name + "_time", Time.get_unix_time_from_system())
		return val_max
	else:
		Saves.set_value("vpet", stat_name, value)
		Saves.set_value("vpet", stat_name + "_time", Time.get_unix_time_from_system())
		return value

static func change_stat(stat_name: String, change: float) -> float:
	var cur_stat: float = get_stat(stat_name)
	return set_stat(stat_name, cur_stat + change)

static func param_exist(stat_name: String, param: String) -> bool:
	return Saves.has("vpet", stat_name + "_" + param)

static func get_param(stat_name: String, param: String) -> bool:
	if param_exist(stat_name, param):
		return Saves.get_or_add("vpet", stat_name + "_" + param,  0.0)
	else:
		return 0.0

static func set_param(stat_name: String, param: String, value: float) -> void:
	Saves.set_value("vpet", stat_name + "_" + param, value)

static func get_time_difference_seconds(time: float) -> float:
	return Time.get_unix_time_from_system() - time

static func get_time_difference_minutes(time: float) -> float:
	return (Time.get_unix_time_from_system() - time)/60.0
