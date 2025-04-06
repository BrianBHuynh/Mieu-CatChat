extends Node


var players: Dictionary = {}

func add_mitigation_data(pid: int, movement_id: int, frame_latency: float) -> void:
	if !players.has(pid):
		players[pid] = {"movement_id": 0, "movement_averages": [], "current_movement": []}
	if players[pid]["movement_id"] == movement_id and frame_latency != 0.0:
		players[pid]["current_movement"].append(frame_latency)
	else:
		players[pid]["movement_id"] = movement_id
		if players[pid]["current_movement"].size() != 0:
			var total: float = 0.0
			var iteration: float = 0.0
			for latency: float in players[pid]["current_movement"]:
				iteration = iteration + 1
				total = total + latency
			players[pid]["movement_averages"].append(total/iteration)
			if players[pid]["movement_averages"].size() > 5:
				players[pid]["movement_averages"].pop_front()

func get_mitigation(pid: int) -> float:
	if players[pid]["movement_averages"].size() != 0:
		var total: float = 0.0
		var iteration: float = 0.0
		for average: float in players[pid]["movement_averages"]:
			iteration = iteration + 1
			total = total + average
		return total/iteration
	elif players[pid]["current_movement"].size() > 0:
		var total: float = 0
		var iteration: float = 0
		for latency: float in players[pid]["current_movement"]:
			iteration = iteration + 1
			total = total + latency
		return total/iteration
	else:
		return 0.0
