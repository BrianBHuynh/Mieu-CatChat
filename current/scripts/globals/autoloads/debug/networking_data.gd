extends Node

var networking_data: Dictionary

func _ready() -> void:
	networking_data = Saves.load_file("networking_data")

func add_val(pid: int, frame_latency: int) -> void:
	if !networking_data.has(pid):
		networking_data[pid] = {}
	if networking_data[pid].has(frame_latency):
		networking_data[pid][frame_latency] = 1
	else:
		networking_data[pid][frame_latency] = networking_data[pid][frame_latency] + 1
