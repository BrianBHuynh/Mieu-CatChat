extends CharacterBody3D


func _ready() -> void:
	GlobalVars.mieu = self
	position = Vector3(Saves.get_or_add("Player","pos_x", position.x), Saves.get_or_add("Player","pos_y", position.y), Saves.get_or_add("Player","pos_z", position.z))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor() and !Ui.chat_box.is_text_box_focused():
		velocity.y = GlobalVars.jump_speed
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir: Vector3
	if Input.is_action_pressed("move_left") and not Input.is_action_just_pressed("move_right"):
		input_dir = Vector3(-1, 0, 0)
	elif Input.is_action_pressed("move_right"):
		input_dir = Vector3(1, 0, 0)
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and !Ui.chat_box.is_text_box_focused():
		if is_on_floor():
			velocity.y = GlobalVars.jump_speed
		velocity.x = move_toward(velocity.x, direction.x * GlobalVars.move_speed, GlobalVars.move_speed)
		velocity.z = move_toward(velocity.z, direction.z * GlobalVars.move_speed, GlobalVars.move_speed)
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, GlobalVars.move_speed)
			velocity.z = move_toward(velocity.z, 0, GlobalVars.move_speed)
		else:
			if not Input.is_action_pressed("jump"):
				velocity.y = move_toward(velocity.y, -2.5, .5)
	
	move_and_slide()
	if SteamLobbies.lobby_id != 0:
			Multithreading.add_task(Callable(SteamP2P.sendMessageToUserFast).bind(0, {"type": "data", "x": GlobalVars.mieu.global_position.x, "y": GlobalVars.mieu.global_position.y, "z": GlobalVars.mieu.global_position.z}))
