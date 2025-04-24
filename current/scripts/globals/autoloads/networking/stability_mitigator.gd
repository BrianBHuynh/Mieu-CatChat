extends Node


var players: Dictionary = {}

func add_mitigation_data(pid: int, movement_id: int, frame_latency: float) -> void:
	if !players.has(pid):
		players[pid] = {"movement_id": -1.0, "total": 0.0, "frame_latencies": [], "mitigation_val": 5.0}
	if players[pid]["movement_id"] == movement_id and frame_latency > 1.0:
		if players[pid]["frame_latencies"].size() == 0:
			players[pid]["frame_latencies"].append(10.0)
			players[pid]["total"] = players[pid]["total"] + 10.0
		else:
			players[pid]["frame_latencies"].append(frame_latency)
			players[pid]["total"] = players[pid]["total"] + frame_latency
		if players[pid]["frame_latencies"].size() > 60:
			players[pid]["total"] = players[pid]["total"] - players[pid]["frame_latencies"].pop_front()
	else:
		players[pid]["movement_id"] = movement_id
	if players[pid]["frame_latencies"].size() >= 30:
		#Uses formula of -mean * ln(.05) to get the upper bound of a 95% confidence interval, modified slightly by shifting the mean down and then adding 2 to the final ammount due to us removing the 0 and 1 values.
		var average: float = players[pid]["total"]/float(players[pid]["frame_latencies"].size())
		players[pid]["mitigation_val"] = (average-2.0) * 2.99573227355 + 2.0

func get_mitigation(pid: int) -> float:
	return players[pid]["mitigation_val"]

func reset_movement_ids() -> void:
	for player: int in players:
		players[player]["movement_id"] = -1
