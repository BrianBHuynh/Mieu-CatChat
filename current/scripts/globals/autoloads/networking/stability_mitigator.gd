extends Node


var players: Dictionary = {}

func add_mitigation_data(pid: int, movement_id: int, frame_latency: float) -> void:
	if !players.has(pid):
		players[pid] = {"movement_id": 0.0, "frame_latencies": [], "mitigation_val": 5.0}
	if players[pid]["movement_id"] == movement_id and frame_latency != 0.0:
		players[pid]["current_movement"].append(frame_latency)
		if players[pid]["current_movement"].size() > 20:
			players[pid]["current_movement"].pop_front()
	else:
		players[pid]["movement_id"] = movement_id
	Multithreading.add_task(update_mitigation.bind(pid))

func update_mitigation(pid: int) -> void:
	if players[pid]["frame_latencies"].size() > 3:
		var total: float = 0.0
		for latency: float in players[pid]["frame_latencies"]:
			total = total + latency
		var average: float = total/players[pid]["frame_latencies"].size()
		total = 0.0
		for latency: float in players[pid]["frame_latencies"]:
			total = total + (average-latency)**2
		var standard_deviation: float = total/(players[pid]["frame_latencies"].size() - 1)
		players[pid]["mitigation_val"].set.bind("mitigation_val", sqrt(total + standard_deviation*3)).defered_call()

func get_mitigation(pid: int) -> float:
	return players[pid]["mitigation_val"]
