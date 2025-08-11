extends Node


func send_message_to_user(payload: Dictionary, this_target: String = "0", send_type: int = Steam.NETWORKING_SEND_RELIABLE, channel: int = 0, encrypted: bool = false) -> void:
	if this_target == "0":
		


func send_chat_message(message: String, this_target: String = "0", private: bool = false, channel: int = 0) -> void:
	pass
