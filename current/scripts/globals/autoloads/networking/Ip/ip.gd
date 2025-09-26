extends Node


func connected_to_multiplayer() -> bool:
	return false


func send_message_to_user(payload: Dictionary, this_target: int = 0, send_type: int = Steam.NETWORKING_SEND_RELIABLE, channel: int = 0, encrypted: bool = false) -> void:
	Multithreading.add_task(_send_message_to_user_task.bind(payload, this_target, send_type, channel, encrypted))


func _send_message_to_user_task(_payload: Dictionary, _this_target: int = 0, _send_type: int = Steam.NETWORKING_SEND_RELIABLE, _channel: int = 0, _encrypted: bool = false) -> void:
	pass


func send_chat_message(message: String, this_target: int = 0, private: bool = false, channel: int = 0) -> void:
	Multithreading.add_task(_send_chat_message_task.bind(message, int(this_target), private, channel))


func _send_chat_message_task(_message: String, _this_target: int = 0, _private: bool = false, _channel: int = 0) -> void:
	pass
