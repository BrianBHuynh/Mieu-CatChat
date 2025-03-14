extends Control


var folder_paths: Array[String] = ["res://current/text/startup_message/"]
var file_paths: Array[String] = []

func _ready() -> void:
	for folder: String in folder_paths:
		for sub_folder: String in DirAccess.get_directories_at(folder):
			folder_paths.append(folder + sub_folder + "/")
	for folder: String in folder_paths:
		for file_path: String in DirAccess.get_files_at(folder):
			file_paths.append(folder + file_path)
	get_next()

func get_next() -> void:
	var next_path: String = file_paths.pop_front()
	file_paths.push_back(next_path)
	$ScrollContainer/HBoxContainer/CreditsOrLicense.text = Helper.get_string_from_txt(next_path)

func get_previous() -> void:
	var last_path: String = file_paths.pop_back()
	file_paths.push_front(last_path)
	$ScrollContainer/HBoxContainer/CreditsOrLicense.text = Helper.get_string_from_txt(last_path)
