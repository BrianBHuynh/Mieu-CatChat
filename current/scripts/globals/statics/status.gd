extends Node
class_name Status


static func init_stat(stat_name: String, stat_value: float, stat_rate: float, stat_max: float, stat_min: float) -> void:
	var temp_dict: Dictionary = {}
	temp_dict["value"] = stat_value
	temp_dict["rate"] = stat_rate
	temp_dict["max"] = stat_max
	temp_dict["min"] = stat_min
	temp_dict["time"] = Time.get_unix_time_from_system()
	Saves.get_or_add("status", stat_name, temp_dict)


static func get_stat(stat_name: String) -> float:
	var temp_dict: Dictionary = Saves.get_or_add("status", stat_name, {})
	if temp_dict.size() == 0:
		return 0.0
	var cur_stat: float = temp_dict.value + (get_time_difference_seconds(temp_dict["time"])*temp_dict["rate"])
	if cur_stat <= temp_dict["min"]:
		return temp_dict["min"]
	elif cur_stat >= temp_dict["max"]:
		return temp_dict["max"]
	else:
		return cur_stat


static func set_stat(stat_name: String, value: float) -> float:
	var temp_dict: Dictionary = Saves.get_or_add("status", stat_name, {})
	if temp_dict.size() == 0:
		return 0.0
	else:
		temp_dict["time"] = Time.get_unix_time_from_system()
		if value <= temp_dict["min"]:
			temp_dict["value"] = temp_dict["min"]
		elif value >= temp_dict["max"]:
			temp_dict["value"] = temp_dict["max"] 
		else:
			temp_dict["value"] = value
		Saves.set_value("status", stat_name, temp_dict)
		return temp_dict["value"]


static func change_stat(stat_name: String, change: float) -> float:
	return set_stat(stat_name, get_stat(stat_name) + change)


static func param_exist(stat_name: String, param: String) -> bool:
	return Saves.get_or_add("status", stat_name, {}).has(param)


static func get_param(stat_name: String, param: String) -> float:
	if param_exist(stat_name, param):
		return Saves.get_or_add("status", stat_name,  {})[param]
	else:
		return 0.0


static func set_param(stat_name: String, parameter: String, value: float) -> void:
	var temp_dict: Dictionary = Saves.get_or_add("status", stat_name, {})
	temp_dict[parameter] = value
	Saves.set_value("status", stat_name, temp_dict)


static func get_time_difference_seconds(time: float) -> float:
	return Time.get_unix_time_from_system() - time


static func get_time_difference_minutes(time: float) -> float:
	return (Time.get_unix_time_from_system() - time)/60.0
