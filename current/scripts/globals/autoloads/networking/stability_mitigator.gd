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
		#Uses formula of -mean * ln(.05) to get the upper bound of a 95% confidence interval, modified slightly by shifting the mean down by 2 due to us removing the 0 and 1 values. The 0 values are invalid since they are = to the non 1 values.
		#We ignore the 1 values as they are so overly represented that it would be a higher performance impact running the calculations every time a frame is sent in when this is in theory the same.
		#We then add a buffer of 2, just to prevent the most common of lag spikes 
		var average: float = players[pid]["total"]/float(players[pid]["frame_latencies"].size())
		players[pid]["mitigation_val"] = (average-2.0) * 2.99573227355 + 2.0

func get_mitigation(pid: int) -> float:
	if players.has(pid):
		return players[pid]["mitigation_val"]
	else:
		return 5.0

func reset_movement_ids() -> void:
	for player: int in players:
		players[player]["movement_id"] = -1
