extends Node

var data: Dictionary = {}
var encryption_key: String = OS.get_unique_id()
var save_extension: String = ".CAT"
var checksum_extension: String = ".COLLAR"

func _ready() -> void:
	make_dir("user://saves")
	make_dir("user://backup")
	make_dir("user://fallback")
	make_dir("user://fonts")
	var temp: Variant = await load_file("mieu")
	if temp != null:
		data = temp
	SignalBus.load_finished.emit()

func set_value(dictionary: String, key: String, value: Variant) -> void:
	if(not data.has(dictionary)):
		data[dictionary] = {}
	data[dictionary][key] = value
	data[dictionary][key] = value

func get_value(dictionary: String, key: String, default_value: Variant) -> Variant:
	return data.get_or_add(dictionary, {}).get_or_add(key, default_value)

func save_game() -> void:
	save_file(data, "mieu")

func add_data(dictionary: String, key: String, content: Variant)-> void:
	if data.has(dictionary):
		data[dictionary][key] = content

func make_dir(dir: String) -> void:
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_absolute(dir)

func save_file(content: Variant, location: String) -> void:
	var content_json: String = JSON.stringify(content)
	await get_tree().create_timer(1.0).timeout 
	write_json(content_json, "user://saves/", location)
	await get_tree().create_timer(1.0).timeout 
	write_json(content_json, "user://backup/", location)
	await get_tree().create_timer(1.0).timeout 
	write_json(content_json, "user://fallback/", location)

func write_json(content: Variant, dir: String, location: String) -> void:
	OpenWrite(dir + location + save_extension).store_var(content, false)
	OpenWrite(dir + location + checksum_extension).store_var(FileAccess.get_sha256(dir + location + save_extension), false)

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

func sanity_check(dir: String, location: String, content: JSON) -> bool:
	var sanity: bool = false
	if (
		FileAccess.file_exists(dir + location + save_extension)
		and FileAccess.file_exists(dir + location + checksum_extension)
		and FileAccess.open_encrypted_with_pass(dir + location + checksum_extension, FileAccess.READ, encryption_key) != null 
		and FileAccess.open_encrypted_with_pass(dir + location + save_extension, FileAccess.READ, encryption_key) != null
	):
		sanity = (
		FileAccess.get_sha256(dir + location + save_extension) == FileAccess.open_encrypted_with_pass(dir + location + checksum_extension, FileAccess.READ, encryption_key).get_var() 
		and content.parse(FileAccess.open_encrypted_with_pass(dir + location + save_extension, FileAccess.READ, encryption_key).get_var(false), false) == OK
		)
	return sanity

func OpenWrite(path: String) -> FileAccess:
	return FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, encryption_key)

func OpenRead(path: String) -> FileAccess:
	return FileAccess.open_encrypted_with_pass(path, FileAccess.READ, encryption_key)
