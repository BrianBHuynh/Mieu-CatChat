extends CharacterBody2D


const Speed: float = 300.0
const Jump_velocity: float = -400.0


func _physics_process(delta: float) -> void:

	var input_dir: Vector2 = Vector2(0, 0)
	if !GlobalVars.is_player_interactive():
		if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
			input_dir = Vector2(-1, 0)
		elif Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
			input_dir = Vector2(1, 0)
	input_dir = input_dir.normalized()
	
	if input_dir:
		velocity.x =  move_toward(velocity.x, GlobalVars.move_speed_2D * input_dir.x, GlobalVars.move_speed_2D)
	else:
		velocity.x = move_toward(velocity.x, 0, GlobalVars.move_speed_2D)
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and !GlobalVars.is_player_interactive():
		velocity.y += Jump_velocity
	
	move_and_slide()
	if SteamLobbies.lobby_id != 0:
			Multithreading.add_task(Callable(SteamP2P.send_message_to_user).bind({"type": "minigame_data", "dimensions": 2,"x": global_position.x, "y": global_position.y}, 0, Steam.NETWORKING_SEND_UNRELIABLE_NO_DELAY))
