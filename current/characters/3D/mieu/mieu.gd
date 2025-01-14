extends CharacterBody3D


func _ready() -> void:
	GlobalVars.mieu = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$CameraOrigin/SpringArm3D.set_length(Saves.get_or_return("settings", "camera_distance", 1.0))
	await get_tree().process_frame
	if $CameraOrigin/SpringArm3D/Camera3D.is_inside_tree():
		$CameraOrigin/SpringArm3D/Camera3D.look_at($CameraOrigin.global_position)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor() and !Ui.chat_box.is_text_box_focused():
		velocity.y = GlobalVars.jump_speed
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir: Vector3 = Vector3(0, 0, 0)
	if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		input_dir = Vector3(-1, 0, 0)
	elif Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
		input_dir = Vector3(1, 0, 0)
	if Input.is_action_pressed("move_forwards") and not Input.is_action_pressed("move_backwards"):
		input_dir = input_dir + Vector3(0, 0, -1)
	elif Input.is_action_pressed("move_backwards") and not Input.is_action_pressed("move_forwards"):
		input_dir = input_dir + Vector3(0, 0, 1)
	input_dir = transform.basis * input_dir.normalized()
	if input_dir and !Ui.chat_box.is_text_box_focused():
		if is_on_floor():
			velocity.y = GlobalVars.jump_speed
		velocity.x = move_toward(velocity.x, input_dir.x * GlobalVars.move_speed_3D, GlobalVars.move_speed_3D)
		velocity.z = move_toward(velocity.z, input_dir.z * GlobalVars.move_speed_3D, GlobalVars.move_speed_3D)
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, GlobalVars.move_speed_3D)
			velocity.z = move_toward(velocity.z, 0, GlobalVars.move_speed_3D)
		else:
			if not Input.is_action_pressed("jump"):
				velocity.y = move_toward(velocity.y, -2.5, .5)
	
	move_and_slide()
	if SteamLobbies.lobby_id != 0:
			Multithreading.add_task(Callable(SteamP2P.sendMessageToUserFast).bind(0, {"type": "data", "dimensions": 3,"x": GlobalVars.mieu.global_position.x, "y": GlobalVars.mieu.global_position.y, "z": GlobalVars.mieu.global_position.z}))

func _input(event: InputEvent) -> void:
	if !Ui.menu_open and !Ui.chat_box.is_text_box_focused():
		if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x*Saves.get_or_return("settings", "mouse_sense", .20)))
			$CameraOrigin.rotate_x(deg_to_rad(-event.relative.y*Saves.get_or_return("settings", "mouse_sense", .20)))
			$CameraOrigin.rotation.x = clamp($CameraOrigin.rotation.x, deg_to_rad(-85), deg_to_rad(40))
			if !is_zero_approx($CameraOrigin/SpringArm3D.get_length()):
				$CameraOrigin/SpringArm3D/Camera3D.look_at($CameraOrigin.global_position)
		elif event is InputEventMouseButton:
			var length: float = $CameraOrigin/SpringArm3D.get_length()
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				$CameraOrigin/SpringArm3D.set_length(length+.1)
				$Sprite.show()
				if $CameraOrigin/SpringArm3D.get_length() >= 25.0:
					$CameraOrigin/SpringArm3D.set_length(25.0)
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				$CameraOrigin/SpringArm3D.set_length(length-.1)
				if $CameraOrigin/SpringArm3D.get_length() <= 0:
					$CameraOrigin/SpringArm3D.set_length(0.0)
					$Sprite.hide()

func get_spring_arm_length() -> float:
	return $CameraOrigin/SpringArm3D.get_length()
