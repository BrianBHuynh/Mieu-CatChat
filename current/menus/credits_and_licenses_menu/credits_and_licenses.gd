extends Control


var folder_paths: Array = ["res://credits/", "res://licenses/"]
var file_paths: Array = []

func _ready() -> void:
	for folder in folder_paths:
		for sub_folder in DirAccess.get_directories_at(folder):
			folder_paths.append(folder + sub_folder + "/")
	for folder in folder_paths:
		for file_path in DirAccess.get_files_at(folder):
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
