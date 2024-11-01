extends Node

var menu_open: bool = false
var menu: Resource = load("res://current/menus/escape_menu/escape_menu.tscn")
var cur_menu: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if not menu_open:
			var new_menu: Control = menu.instantiate()
			get_tree().root.add_child(new_menu)
			cur_menu = new_menu
			menu_open = true
		else:
			get_tree().root.remove_child(cur_menu)
			cur_menu = null
			menu_open = false
