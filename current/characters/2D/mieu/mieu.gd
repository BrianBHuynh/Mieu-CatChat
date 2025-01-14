extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:

	var input_dir: Vector2 = Vector2(0, 0)
	if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		input_dir = Vector2(-1, 0)
	elif Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
		input_dir = Vector2(1, 0)
	if Input.is_action_pressed("move_forwards") and not Input.is_action_pressed("move_backwards"):
		input_dir = input_dir + Vector2(0, -1)
	elif Input.is_action_pressed("move_backwards") and not Input.is_action_pressed("move_forwards"):
		input_dir = input_dir + Vector2(0, 1)
	input_dir = input_dir.normalized()
	
	if input_dir and !Ui.chat_box.is_text_box_focused():
		velocity.x = move_toward(velocity.y, input_dir.y * GlobalVars.move_speed, GlobalVars.move_speed)
		velocity.y = move_toward(velocity.x, input_dir.x * GlobalVars.move_speed, GlobalVars.move_speed)
	else:
		velocity.x = move_toward(velocity.x, 0, GlobalVars.move_speed)
		velocity.y = move_toward(velocity.y, 0, GlobalVars.move_speed)
	move_and_slide()
