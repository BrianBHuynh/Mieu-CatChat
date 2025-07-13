extends Node


#This class needs to allow people to relay data from one UUID to another. This makes it so that if you are not directly connected to someone else BUT the people you're connected to ARE connected to someone else, it relays through the in between person.
#This prevents ip addresses from being leaked between untrusted users.
var direct_connections: Dictionary = {}
var jump_connections: Dictionary = {}


func find_shortest_path() -> Array:
	return []


func add_direct_connection(id: String, ip: String) -> void:
	direct_connections[id] = WebSocketPeer.new()


func ping(id: String) -> void:
	pass
	#This should send a ping over the network, a "pong" should be returned by another player


func pong(id: String) -> void:
	pass
	#response of getting a ping
