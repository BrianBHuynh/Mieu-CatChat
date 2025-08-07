extends Node


var ids: Dictionary = {}


func _ready() -> void:
	ids.set("Steam", {})
	ids.set("Ip", {})


func add_id(id: String) -> void:
	if is_steam_id("Steam"):
		ids["Steam"][id.lstrip("Steam")] = {}
	elif is_ip_id("Ip"):
		ids["Ip"][id.lstrip("Ip")] = {}


func get_id(id: String) -> Dictionary:
	if is_steam_id("Steam"):
		return ids["Steam"].get_or_return(id.lstrip("Steam"), {})
	elif is_ip_id("Ip"):
		return ids["Ip"].get_or_return(id.lstrip("Ip"), {})
	else:
		return {}


func get_id_var(id: String, key: String) -> Variant:
	if is_steam_id("Steam"):
		return ids["Steam"].get_or_return(id.lstrip("Steam"), {}).get_or_return(key, null)
	elif is_ip_id("Ip"):
		return ids["Ip"].get_or_return(id.lstrip("Ip"), {}).get_or_return(key, null)
	else:
		return null


func is_steam_id(id: String) -> bool:
	return id.begins_with("Steam")


func is_ip_id(id: String) -> bool:
	return id.begins_with("Ip")
