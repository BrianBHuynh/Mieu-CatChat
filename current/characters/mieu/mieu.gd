extends CharacterBody2D


var last_pos: Vector2 = Vector2(-1, -1)
var total_delta: float = 0.0
var jumping: bool = false
var since_last_synced: int = 0
var moving: bool = false
var scene_changing: bool = false


func _ready() -> void:
	GlobalVars.movement_id = GlobalVars.movement_id + 1
	GlobalVars.mieu = self
	GlobalVars.sprite_offset = $Sprite.position
	GlobalVars.reset_position = global_position
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$Sprite/RichTextLabel.text = "[center]" + SteamWorks.steam_username + "[/center]"


func _physics_process(delta: float) -> void:
	movement_logic()
	jumping_logic(delta)
	global_position = global_position.clamp(Vector2(0.0,0.0), Vector2(1920.0, 1080.0))
	if Input.is_action_pressed("jump") and !jumping and GlobalVars.is_player_interactive():
		jumping = true
		set_frame(2)
		send_location(Steam.NETWORKING_SEND_UNRELIABLE_NO_DELAY, get_frame())
	elif moving:
		send_location()


func send_location(send_method: int = Steam.NETWORKING_SEND_UNRELIABLE_NO_DELAY, frame: int = -1) -> void:
	if SteamLobbies.lobby_id != 0 and is_visible_in_tree() and GlobalVars.is_debug_sendable():
		if frame == -1:
			P2P.send_message_to_user({"type": "data", "x": global_position.x, "y": global_position.y, "sprite_y": $Sprite.position.y, "movement_id": GlobalVars.movement_id}, 0, send_method)
		else:
			P2P.send_message_to_user({"type": "data", "x": global_position.x, "y": global_position.y, "sprite_y": $Sprite.position.y, "movement_id": GlobalVars.movement_id, "frame": frame}, 0, send_method)
		last_pos = $Sprite.global_position


func movement_logic() -> void:
	var input_dir: Vector2 = Vector2(0, 0)
	if GlobalVars.is_player_interactive():
		if Input.is_action_pressed("move_left"):
			input_dir.x = -1
		elif Input.is_action_pressed("move_right"):
			input_dir.x = input_dir.x + 1
		if Input.is_action_pressed("move_forwards"):
			input_dir.y = -1
		elif Input.is_action_pressed("move_backwards"):
			input_dir.y = input_dir.y + 1
	input_dir = input_dir.normalized()
	if moving:
		if input_dir == Vector2(0,0) and !jumping:
			GlobalVars.movement_id = GlobalVars.movement_id + 1
			moving = false
			if GlobalVars.movement_id >= 100:
				GlobalVars.movement_id = 0
	elif input_dir != Vector2(0, 0) or jumping:
		moving = true
	
	if !scene_changing:
		if input_dir and GlobalVars.is_player_interactive():
			velocity.x =  move_toward(velocity.x, GlobalVars.move_speed * input_dir.x, GlobalVars.move_speed)
			velocity.y = move_toward(velocity.y, GlobalVars.move_speed * input_dir.y, GlobalVars.move_speed)
		else:
			velocity.x = move_toward(velocity.x, 0, GlobalVars.move_speed)
			velocity.y = move_toward(velocity.y, 0, GlobalVars.move_speed)
	else:
		if input_dir and GlobalVars.is_player_interactive():
			if (
				(input_dir.x > 0.0 and global_position.direction_to(WorldManager.door_position).x > 0.0) 
				or (input_dir.x < 0.0 and global_position.direction_to(WorldManager.door_position).x < 0.0)
				):
				velocity.x =  move_toward(velocity.x, GlobalVars.move_speed * input_dir.x, GlobalVars.move_speed)
			else:
				velocity.x = 0.0
			if (
				(input_dir.y > 0.0 and global_position.direction_to(WorldManager.door_position).y > 0.0) 
				or (input_dir.y < 0.0 and global_position.direction_to(WorldManager.door_position).y < 0.0)
				):
				velocity.y = move_toward(velocity.y, GlobalVars.move_speed * input_dir.y, GlobalVars.move_speed)
			else:
				velocity.y = 0.0
		else:
			velocity.x = move_toward(velocity.x, 0, GlobalVars.move_speed)
			velocity.y = move_toward(velocity.y, 0, GlobalVars.move_speed)
	
	move_and_slide()


func jumping_logic(delta: float) -> void:
	if jumping:
		if $Sprite.position.y <= GlobalVars.sprite_offset.y:
			total_delta = delta+total_delta
			$Sprite.position.y = (GlobalVars.sprite_offset.y + (981.0)*(total_delta - .2765)**2 - 75.0)
			$Shadow.scale = Vector2(.5, .25) * (($Sprite.position.y - GlobalVars.sprite_offset.y)/300.0 + 1)
		else:
			$Sprite.position = GlobalVars.sprite_offset
			$Shadow.scale = Vector2(.5, .25)
			total_delta = 0.0
			jumping = false


func get_frame() -> int:
	return $Sprite.frame


func set_frame(frame: int) -> void:
	$Sprite.frame = frame
	$Shadow.frame = frame
