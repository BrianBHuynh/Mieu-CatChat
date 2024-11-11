extends CharacterBody3D


var move_speed: float = 7.5
var jump_speed: float = 2.5

func _ready() -> void:
	#hacky
	GlobalVars.mieu = self
	var temp: Variant = Saves.data.get_or_add("Player", {}).get_or_add("pos", str(position))
	temp = temp.erase(0, 1)
	temp = temp.erase(temp.length()-1, 1)
	temp = temp.split(", ", true, 0)
	position = Vector3(temp[0].to_float(), temp[1].to_float(), temp[2].to_float())

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_speed
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir: Vector3
	if Input.is_action_pressed("move_left") and not Input.is_action_just_pressed("move_right"):
		input_dir = Vector3(-1, 0, 0)
	elif Input.is_action_pressed("move_right"):
		input_dir = Vector3(1, 0, 0)
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if is_on_floor():
			velocity.y = jump_speed
		velocity.x = move_toward(velocity.x, direction.x * move_speed, move_speed)
		velocity.z = move_toward(velocity.z, direction.z * move_speed, move_speed)
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)
		else:
			if not Input.is_action_pressed("jump"):
				velocity.y = move_toward(velocity.y, -2.5, .5)
	
	move_and_slide()
