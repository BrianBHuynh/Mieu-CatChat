extends CharacterBody2D


func _ready() -> void:
	GlobalVars.mieu = self
	GlobalVars.reset_position = global_position
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(_delta: float) -> void:
	var input_dir: Vector2 = Vector2(0, 0)
	if GlobalVars.is_player_interactive():
		if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
			input_dir = Vector2(-1, 0)
		elif Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
			input_dir = Vector2(1, 0)
		if Input.is_action_pressed("move_forwards") and not Input.is_action_pressed("move_backwards"):
			input_dir = input_dir + Vector2(0, -1)
		elif Input.is_action_pressed("move_backwards") and not Input.is_action_pressed("move_forwards"):
			input_dir = input_dir + Vector2(0, 1)
	input_dir = input_dir.normalized()
	
	if input_dir and GlobalVars.is_player_interactive():
		velocity.x =  move_toward(velocity.x, GlobalVars.move_speed_2D * input_dir.x, GlobalVars.move_speed_2D)
		velocity.y = move_toward(velocity.y, GlobalVars.move_speed_2D * input_dir.y, GlobalVars.move_speed_2D)
	else:
		velocity.x = move_toward(velocity.x, 0, GlobalVars.move_speed_2D)
		velocity.y = move_toward(velocity.y, 0, GlobalVars.move_speed_2D)
	
	move_and_slide()
	global_position = global_position.clamp(Vector2(0.0,0.0), Vector2(1920.0, 1080.0))
	
	if SteamLobbies.lobby_id != 0:
			Multithreading.add_task(SteamP2P.send_message_to_user.bind({"type": "data", "dimensions": 2,"x": global_position.x, "y": global_position.y}, 0, Steam.NETWORKING_SEND_UNRELIABLE_NO_DELAY))
