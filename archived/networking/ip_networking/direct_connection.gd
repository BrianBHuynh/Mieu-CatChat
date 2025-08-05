extends Node
class_name DirectConnection


var socket: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
var opened: bool = false


func _ready() -> void:
	socket.create_server(48, "*", null)


func set_socket(ip: String) -> void:
	socket.connect_to_url(ip)


func _process(delta) -> void:
	socket.poll()
	match socket.get_ready_state():
		WebSocketPeer.STATE_OPEN:
			while socket.get_available_packet_count():
				pass
				#to get packet --> socket.get_packet()
		WebSocketPeer.STATE_CLOSED:
			if opened:
				queue_free()
		_:
			pass
