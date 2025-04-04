extends Node


var players: Dictionary = {}

func add_player(pid: int) -> void:
	players[pid] = {"movement_id": 0, "movement_averages": [], "current_movement": []}

func add_mitigation_data(pid: int, movment_id: int, frame_latency: int) -> int:
	if players[pid]["movement_id"] == movment_id:
		players[pid]["current_movement"].append(frame_latency)
	else:
		players[pid]["movement_id"] = movment_id
		if players[pid]["current_movement"].size() != 0:
			var total: int = 0
			var iteration: int = 0
			for latency in players[pid]["frame_latency"]:
				iteration = iteration + 1
				total = total + latency
			players[pid]["movement_averages"].append(total/iteration)
			if players[pid]["movement_averages"].size() > 5:
				players[pid]["movement_averages"].pop_front()
	
	return get_mitigation(pid)

func get_mitigation(pid: int) -> int:
	if players[pid]["movment_averages"].size() != 0:
		var total: int = 0
		var iteration: int = 0
		for average in players[pid]["movment_averages"]:
			iteration = iteration + 1
			total = total + average
		return total/iteration
	elif players[pid]["frame_latency"].size() > 0:
		var total: int = 0
		var iteration: int = 0
		for latency in players[pid]["frame_latency"]:
			iteration = iteration + 1
			total = total + latency
		return total/iteration
	else:
		return 0
