extends Node

var data: Dictionary = {}


func _ready() -> void:
	make_dir("user://saves")
	make_dir("user://backup")
	make_dir("user://fallback")
	var temp: Variant = await load_file("mieu")
	if temp != null:
		data = temp
	SignalBus.load_finished.emit()

func set_value(dictionary: String, key: String, value: Variant) -> void:
	if(not data.has(dictionary)):
		data[dictionary] = {}
	data[dictionary][key] = value
	data[dictionary][key] = value

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
	OpenWrite(dir + location + ".lanhPACK").store_var(content, false)
	OpenWrite(dir + location + ".lanhCERT").store_var(FileAccess.get_sha256(dir + location + ".lanhPACK"), false)

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
		push_warning("File damaged beyond repair!")
		return null

func sanity_check(dir: String, location: String, content: JSON) -> bool:
	return FileAccess.file_exists(dir + location + ".lanhPACK") and FileAccess.get_sha256(dir + location + ".lanhPACK") == FileAccess.open_encrypted_with_pass(dir + location + ".lanhCERT", FileAccess.READ, OS.get_unique_id()).get_var() and content.parse(FileAccess.open_encrypted_with_pass(dir + location + ".lanhPACK", FileAccess.READ, OS.get_unique_id()).get_var(false), false) == OK

func OpenWrite(path: String) -> FileAccess:
	return FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, OS.get_unique_id())

func OpenRead(path: String) -> FileAccess:
	return FileAccess.open_encrypted_with_pass(path, FileAccess.READ, OS.get_unique_id())
