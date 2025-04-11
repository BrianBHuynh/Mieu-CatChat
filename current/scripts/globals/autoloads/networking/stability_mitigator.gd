extends Node


var players: Dictionary = {}

func add_mitigation_data(pid: int, movement_id: int, frame_latency: float) -> void:
	if !players.has(pid):
		players[pid] = {"movement_id": 0.0, "frame_latencies": [], "mitigation_val": 5.0}
	if players[pid]["movement_id"] == movement_id and frame_latency >= 1.0:
		players[pid]["frame_latencies"].append(frame_latency)
		if players[pid]["frame_latencies"].size() > 30:
			players[pid]["frame_latencies"].pop_front()
	else:
		players[pid]["movement_id"] = movement_id
	Multithreading.add_task(update_mitigation.bind(pid, players[pid].duplicate()))

func update_mitigation(pid: int, mitigation_data: Dictionary) -> void:
	if mitigation_data["frame_latencies"].size() > 10:
		var total: float = 0.0
		for latency: float in mitigation_data["frame_latencies"]:
			total = total + latency
		var average: float = total/mitigation_data["frame_latencies"].size()
		total = 0.0
		for latency: float in mitigation_data["frame_latencies"]:
			total = total + (average-latency)**2
		var standard_deviation: float = total/(mitigation_data["frame_latencies"].size() - 1)
		set_mitigation_val.call_deferred(pid, sqrt(total + standard_deviation*3))

func set_mitigation_val(pid: int, new_val: float) -> void:
	players[pid]["mitigation_val"] = new_val

func get_mitigation(pid: int) -> float:
	return players[pid]["mitigation_val"]
