extends Node


#This class needs to allow people to relay data from one UUID to another. This makes it so that if you are not directly connected to someone else BUT the people you're connected to ARE connected to someone else, it relays through the in between person.
#This prevents ip addresses from being leaked between untrusted users.
var direct_connections: Dictionary = {}
var jump_connections: Dictionary = {}


func find_shortest_path(id: String) -> Array:
	var paths: Dictionary = {}
	for connection in jump_connections:
		if jump_connections[connection].has(id):
			pass
			#Ping jump connection to see how long ping is on this jump connection.
	return []


func add_direct_connection(id: String, ip: String) -> void:
	if not direct_connections.has(id):
		direct_connections[id] = WebSocketPeer.new()
		direct_connections[id].connect_to_url("ip")


func add_indirect_connection(id: String, connection: String) -> void:
	if not jump_connections.has(connection):
		jump_connections[connection] = {}
	if not jump_connections[connection].has(id):
		jump_connections[connection][id] = {} 
