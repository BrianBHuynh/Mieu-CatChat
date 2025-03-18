extends Node2D


var instanced: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WorldManager.update_world(self)
	WorldManager.set_door($Middleground/DoorA, "A")
	WorldManager.set_door($Middleground/DoorB, "B")

func _on_door_a_body_entered(body: Node2D) -> void:
	WorldManager.door_teleport(body, "res://current/scenes/worlds/sketch_worlds/park/park.tscn", "B", $Middleground/Mieu.global_position - $Middleground/DoorA.get_child(0).global_position)

func _on_door_b_body_entered(body: Node2D) -> void:
	WorldManager.door_teleport(body, "res://current/scenes/templates/scene_template/scene_template.tscn", "A", $Middleground/Mieu.global_position - $Middleground/DoorB.get_child(0).global_position)
