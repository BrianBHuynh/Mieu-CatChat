extends Node

var data: Dictionary = {}
var settings: Dictionary = {}
var player_data: Dictionary = {}
var encryption_key: String = OS.get_unique_id()
var save_extension: String = ".CAT"
var checksum_extension: String = ".COLLAR"

func _ready() -> void:
	make_dir("user://saves")
	make_dir("user://backup")
	make_dir("user://fallback")
	make_dir("user://fonts")
	var data_temp: Variant = load_file_encrypted("mieu")
	if data_temp != null:
		data = data_temp
	var settings_temp: Variant = load_file("settings")
	if settings_temp != null:
		settings = settings_temp
	var player_data_temp: Variant = load_file("player_data")
	if player_data_temp != null:
		player_data = player_data_temp
	SignalBus.load_finished.emit()

func set_value(dictionary: String, key: String, value: Variant) -> void:
	if(not data.has(dictionary)):
		data[dictionary] = {}
	data[dictionary][key] = value

func has(dictionary: String, key: String) -> bool:
	if data.has(dictionary) && data[dictionary].has(key):
		return true
	else:
		return false

func get_or_add(dictionary: String, key: String, default_value: Variant) -> Variant:
	if(not data.has(dictionary)):
		data[dictionary] = {}
	return data.get_or_add(dictionary, {}).get_or_add(key, default_value)

func save_game() -> void:
	Multithreading.add_task(save_file_encrypted.bind(data, "mieu"))
	Multithreading.add_task(save_file.bind(settings, "settings"))
	Multithreading.add_task(save_file.bind(player_data, "player_data"))

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

func write_json_encrypted(content: Variant, dir: String, location: String) -> void:
	open_write_encrypted(dir + location + save_extension).store_line(content)
	open_write_encrypted(dir + location + checksum_extension).store_line(FileAccess.get_sha256(dir + location + save_extension))

func write_json(content: Variant, dir: String, location: String) -> void:
	open_write(dir + location + save_extension).store_line(content)
	open_write(dir + location + checksum_extension).store_line(FileAccess.get_sha256(dir + location + save_extension))

func load_file_encrypted(location: String) -> Variant:
	var content: JSON = JSON.new()
	if sanity_check_encrypted("user://saves/", location, content):
		print("File 1 passed all checks")
		return content.data
	elif sanity_check_encrypted("user://backup/", location, content):
		print("File 1 has failed it's checks, file 2 passed all checks")
		return content.data
	elif sanity_check_encrypted("user://fallback/", location, content):
		print("File 1 and 2 have failed their checks, file 3 passed all checks")
		return content.data
	else:
		push_warning("File could not be loaded!")
		return null

func load_file(location: String) -> Variant:
	var content: JSON = JSON.new()
	if sanity_check("user://saves/", location, content):
		print("File 1 passed all checks")
		return content.data
	elif sanity_check("user://backup/", location, content):
		print("File 1 has failed it's checks, file 2 passed all checks")
		return content.data
	elif sanity_check("user://fallback/", location, content):
		print("File 1 and 2 have failed their checks, file 3 passed all checks")
		return content.data
	else:
		push_warning("File could not be loaded!")
		return null

func sanity_check_encrypted(dir: String, location: String, content: JSON) -> bool:
	var sanity: bool = false
	if (
		FileAccess.file_exists(dir + location + save_extension)
		and FileAccess.file_exists(dir + location + checksum_extension)
		and open_read_encrypted(dir + location + checksum_extension) != null 
		and open_read_encrypted(dir + location + save_extension) != null
	):
		sanity = (
		FileAccess.get_sha256(dir + location + save_extension) == open_read_encrypted(dir + location + checksum_extension).get_line()
		and content.parse(open_read_encrypted(dir + location + save_extension).get_as_text()) == OK
		)
	return sanity

func sanity_check(dir: String, location: String, content: JSON) -> bool:
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

func open_write_encrypted(path: String) -> FileAccess:
	return FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, encryption_key)

func open_write(path: String) -> FileAccess:
	return FileAccess.open(path, FileAccess.WRITE)

func open_read_encrypted(path: String) -> FileAccess:
	return FileAccess.open_encrypted_with_pass(path, FileAccess.READ, encryption_key)

func open_read(path: String) -> FileAccess:
	return FileAccess.open(path, FileAccess.READ)
