extends Node2D


var instanced: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WorldManager.update_world(self)
	WorldManager.set_door($Middleground/DoorA, "A")

func _on_door_a_body_entered(body: Node2D) -> void:
	WorldManager.door_teleport(body, "sketch_worlds/park/park.tscn", "C", $Middleground/Mieu.global_position - $Middleground/DoorA.get_child(0).global_position)
