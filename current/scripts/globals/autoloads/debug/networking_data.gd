extends Node

var networking_data: Dictionary
var chance: int = 1
var gap: int = 0
var current_gap_frame: int = 0

func _ready() -> void:
	networking_data = Saves.load_file("networking_data")

func add_val(pid: int, frame_latency: int) -> void:
	if !networking_data.has(pid):
		networking_data[pid] = {}
	if networking_data[pid].has(frame_latency):
		networking_data[pid][frame_latency] = 1
	else:
		networking_data[pid][frame_latency] = networking_data[pid][frame_latency] + 1

func frame_sendable() -> bool:
	if current_gap_frame >= gap:
		current_gap_frame = 0
		return true
	else:
		current_gap_frame = current_gap_frame + 1
		return false
