extends Node


var data: Dictionary = {}
var settings: Dictionary = {}
var networking: Dictionary = {}
var encryption_key: String = OS.get_unique_id()
var save_loaded: bool = false
const save_extension: String = ".MIEU"
const checksum_extension: String = ".COLLAR"
var autosave_tick: int = 0
var autosave_interval: int = 36000

func _ready() -> void:
	make_dir("user://saves")
	make_dir("user://backup")
	make_dir("user://fallback")
	make_dir("user://fonts")
	data = load_file_encrypted("mieu")
	if data.is_empty():
		Ui.show_system_message("It looks like this is your first time playing mieu :D welcome!")
	settings = load_file("settings")
	networking = load_file("networking")
	MinigameManager.minigame_stats = Saves.load_file_encrypted("minigame_stats")
	SignalBus.load_finished.emit()
	save_loaded = true
	await get_tree().process_frame
	if FileAccess.file_exists("res://current/scenes/worlds/" + get_or_return("player", "world_path", "res://current/scenes/worlds/scene_template/scene_template.tscn")):
		WorldManager.change_world(get_or_return("player", "world_path", "res://current/scenes/worlds/scene_template/scene_template.tscn"))
	else:
		WorldManager.change_world("scene_template/scene_template.tscn")

func _physics_process(_delta: float) -> void:
	auto_save()

func auto_save() -> void:
	autosave_tick = autosave_tick + 1
	if autosave_tick > autosave_interval:
		autosave_tick = 0
		while get_tree() == null:
			await get_tree().process_frame
		if get_or_add("settings", "auto_save", true):
			save_game()
		Ui.show_system_debug("auto saving!")

func set_value(dictionary: String, key: String, value: Variant) -> void:
	match dictionary:
		"settings":
			settings[key] = value
		"networking":
			networking[key] = value
		_:
			if(not data.has(dictionary)):
				data[dictionary] = {}
			data[dictionary][key] = value

func has(dictionary: String, key: String) -> bool:
	if data.has(dictionary) and data[dictionary].has(key):
		return true
	else:
		return false

func get_or_add(dictionary: String, key: String, default_value: Variant) -> Variant:
	match dictionary:
		"settings":
			return settings.get_or_add(key, default_value)
		"networking":
			return networking.get_or_add(key, default_value)
		"minigame_stats":
			return MinigameManager.minigame_stats.get_or_add(key, default_value)
		_:
			return data.get_or_add(dictionary, {}).get_or_add(key, default_value)

func get_or_return(dictionary: String, key: String, default_value: Variant) -> Variant:
	match dictionary:
		"settings":
			return settings.get(key, default_value)
		"networking":
			return networking.get(key, default_value)
		"minigame_stats":
			return MinigameManager.minigame_stats.get(key, default_value)
		_:
			return data.get(dictionary, {}).get(key, default_value)

func save_game() -> void:
	store_player_state()
	await get_tree().process_frame
	Multithreading.add_task(save_file_encrypted.bind(data, "mieu"))
	Multithreading.add_task(save_file_encrypted.bind(MinigameManager.minigame_stats, "minigame_stats"))
	Multithreading.add_task(save_file.bind(settings, "settings"))
	Multithreading.add_task(save_file.bind(networking, "networking"))

func store_player_state() -> void:
	while !is_instance_valid(GlobalVars.mieu):
		await get_tree().process_frame
	Saves.set_value("player", "pos_x", GlobalVars.mieu.global_position.x)
	Saves.set_value("player", "pos_y", GlobalVars.mieu.global_position.y)

func make_dir(dir: String) -> void:
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_absolute(dir)

func save_file(content: Variant, location: String) -> void:
	var content_json: String = JSON.stringify(content, "\t")
	write_json(content_json, "user://saves/", location)
	write_json(content_json, "user://backup/", location) 
	write_json(content_json, "user://fallback/", location)

func save_file_encrypted(content: Variant, location: String) -> void:
	var content_json: String = JSON.stringify(content, "\t")
	write_json_encrypted(content_json, "user://saves/", location) 
	write_json_encrypted(content_json, "user://backup/", location) 
	write_json_encrypted(content_json, "user://fallback/", location)
	save_file(data, location + ".readable")

func write_json_encrypted(content: Variant, dir: String, location: String) -> void:
	open_write_encrypted(dir + location + save_extension).store_line(content)
	open_write_encrypted(dir + location + checksum_extension).store_line(FileAccess.get_sha256(dir + location + save_extension))

func write_json(content: Variant, dir: String, location: String) -> void:
	open_write(dir + location + save_extension).store_line(content)

func load_file_encrypted(location: String) -> Variant:
	var content: JSON = JSON.new()
	if sanity_check_encrypted("user://saves/", location, content):
		Ui.show_system_debug("File 1 passed all checks")
		return content.data
	elif sanity_check_encrypted("user://backup/", location, content):
		Ui.show_system_debug("File 1 has failed it's checks, file 2 passed all checks")
		return content.data
	elif sanity_check_encrypted("user://fallback/", location, content):
		Ui.show_system_debug("File 1 and 2 have failed their checks, file 3 passed all checks")
		return content.data
	else:
		Ui.show_system_debug("File could not be loaded! (" + location + ")")
		return {}

func load_file(location: String) -> Variant:
	var content: JSON = JSON.new()
	if sanity_check("user://saves/", location, content):
		Ui.show_system_debug("File 1 passed all checks")
		return content.data
	elif sanity_check("user://backup/", location, content):
		Ui.show_system_debug("File 1 has failed it's checks, file 2 passed all checks")
		return content.data
	elif sanity_check("user://fallback/", location, content):
		Ui.show_system_debug("File 1 and 2 have failed their checks, file 3 passed all checks")
		return content.data
	else:
		Ui.show_system_debug("File could not be loaded! (" + location + ")")
		return {}

func sanity_check_encrypted(dir: String, location: String, content: JSON) -> bool:
	if (
		FileAccess.file_exists(dir + location + save_extension)
		and FileAccess.file_exists(dir + location + checksum_extension)
		and open_read_encrypted(dir + location + checksum_extension) != null 
		and open_read_encrypted(dir + location + save_extension) != null
	):
		return (
		FileAccess.get_sha256(dir + location + save_extension) == open_read_encrypted(dir + location + checksum_extension).get_line()
		and content.parse(open_read_encrypted(dir + location + save_extension).get_as_text()) == OK
		)
	return false

func sanity_check_checksum(dir: String, location: String, content: JSON) -> bool:
	var sanity: bool = false
	if (
		FileAccess.file_exists(dir + location + save_extension)
		and FileAccess.file_exists(dir + location + checksum_extension)
		and open_read(dir + location + checksum_extension) != null 
		and open_read(dir + location + save_extension) != null
	):
		sanity = (
		FileAccess.get_sha256(dir + location + save_extension) == open_read(dir + location + checksum_extension).get_line() 
		and content.parse(open_read(dir + location + save_extension).get_as_text()) == OK
		)
	return sanity

func sanity_check(dir: String, location: String, content: JSON) -> bool:
	var sanity: bool = false
	if (
		FileAccess.file_exists(dir + location + save_extension) and open_read(dir + location + save_extension) != null
	):
		sanity = content.parse(open_read(dir + location + save_extension).get_as_text()) == OK
	return sanity

func open_write_encrypted(path: String) -> FileAccess:
	return FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, encryption_key)

func open_write(path: String) -> FileAccess:
	return FileAccess.open(path, FileAccess.WRITE)

func open_read_encrypted(path: String) -> FileAccess:
	return FileAccess.open_encrypted_with_pass(path, FileAccess.READ, encryption_key)

func open_read(path: String) -> FileAccess:
	return FileAccess.open(path, FileAccess.READ)
