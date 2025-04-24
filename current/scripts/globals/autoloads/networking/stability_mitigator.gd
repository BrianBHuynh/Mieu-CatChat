extends Node


var players: Dictionary = {}

func add_mitigation_data(pid: int, movement_id: int, frame_latency: int) -> void:
	if !players.has(pid):
		players[pid] = {"movement_id": -1.0, "frame_latencies": [], "mitigation_val": 5.0}
	if players[pid]["movement_id"] == movement_id and frame_latency > 1.0:
		if players[pid]["frame_latencies"].size() == 0:
			players[pid]["frame_latencies"].append(10.0)
		else:
			players[pid]["frame_latencies"].append(frame_latency)
		if players[pid]["frame_latencies"].size() > 30:
			players[pid]["frame_latencies"].pop_front()
	else:
		players[pid]["movement_id"] = movement_id
	if players[pid]["frame_latencies"].size() >= 30:
		Multithreading.add_task(update_mitigation.bind(pid))

func update_mitigation(pid: int) -> void:
	var total: float = 0.0
	for latency: float in players[pid]["frame_latencies"]:
		total = total + latency
	var average: float = total/players[pid]["frame_latencies"].size()
	total = 0.0
	for latency: float in players[pid]["frame_latencies"]:
		total = total + (average-latency)**2
	var standard_deviation: float = sqrt(total/(players[pid]["frame_latencies"].size() - 1))
	players[pid]["mitigation_val"] = average + standard_deviation*3

func get_mitigation(pid: int) -> float:
	return players[pid]["mitigation_val"]

func reset_movement_ids() -> void:
	for player: int in players:
		players[player]["movement_id"] = -1
