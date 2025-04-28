extends Area2D


@export var path: String
@export var target_door: String
@export var door: String
@export var instance_id: int = -1

func _ready() -> void:
	area_entered.connect(teleport)
	WorldManager.set_door(self, door)

func teleport(area: Area2D) -> void:
	WorldManager.door_teleport(area.get_parent(), path, target_door, GlobalVars.mieu.global_position - get_child(0).global_position, instance_id)
