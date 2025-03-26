extends CharacterBody2D


var last_pos: Vector2 = Vector2(-1, -1)
var total_delta: float = 0.0
var jumping: bool = false
var since_last_synced: int = 0

func _ready() -> void:
	GlobalVars.mieu = self
	GlobalVars.sprite_offset = $Sprite.position
	GlobalVars.reset_position = global_position
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$Sprite/RichTextLabel.text = "[center]" + SteamWorks.steam_username + "[/center]"

func _physics_process(delta: float) -> void:
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
		velocity.x =  move_toward(velocity.x, GlobalVars.move_speed * input_dir.x, GlobalVars.move_speed)
		velocity.y = move_toward(velocity.y, GlobalVars.move_speed * input_dir.y, GlobalVars.move_speed)
	else:
		velocity.x = move_toward(velocity.x, 0, GlobalVars.move_speed)
		velocity.y = move_toward(velocity.y, 0, GlobalVars.move_speed)
	
	move_and_slide()
	global_position = global_position.clamp(Vector2(0.0,0.0), Vector2(1920.0, 1080.0))
	
	if jumping and $Sprite.position.y <= GlobalVars.sprite_offset.y:
		total_delta = delta+total_delta
		$Sprite.position.y = (GlobalVars.sprite_offset.y + (981.0)*(total_delta - .2765)**2 - 75.0)
	elif jumping:
		$Sprite.position = GlobalVars.sprite_offset
		total_delta = 0.0
		jumping = false
	
	if Input.is_action_pressed("jump") and !jumping:
		jumping = true
		set_frame(2)
		send_location(Steam.NETWORKING_SEND_UNRELIABLE_NO_DELAY, get_frame())
	elif last_pos != $Sprite.global_position:
		send_location()

func send_location(send_method: int = Steam.NETWORKING_SEND_UNRELIABLE_NO_DELAY, frame: int = -1) -> void:
	if SteamLobbies.lobby_id != 0 and is_visible_in_tree():
		if frame == -1:
			Multithreading.add_task(SteamP2P.send_message_to_user.bind({"type": "data", "x": global_position.x, "y": global_position.y, "sprite_x": $Sprite.global_position.x, "sprite_y": $Sprite.global_position.y}, 0, send_method))
		else:
			Multithreading.add_task(SteamP2P.send_message_to_user.bind({"type": "data", "x": global_position.x, "y": global_position.y, "sprite_x": $Sprite.global_position.x, "sprite_y": $Sprite.global_position.y, "frame": frame}, 0, send_method))
		last_pos = $Sprite.global_position

func get_frame() -> int:
	return $Sprite.frame

func set_frame(frame: int) -> void:
	$Sprite.frame = frame
	$Shadow.frame = frame
