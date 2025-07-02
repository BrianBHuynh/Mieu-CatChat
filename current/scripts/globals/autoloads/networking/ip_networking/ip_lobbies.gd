extends Node


#This class needs to allow people to relay data from one UUID to another. This makes it so that if you are not directly connected to someone else BUT the people you're connected to ARE connected to someone else, it relays through the in between person.
#This prevents ip addresses from being leaked between untrusted users.
var direct_connections: Dictionary = {}
var jump_connections: Dictionary = {}
var paths: Dictionary = {}
