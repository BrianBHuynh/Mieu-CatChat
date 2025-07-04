extends Node2D


var id: String
var player_name: String
var since_last_frame: float = 0


func _ready() -> void:
	create_tween().tween_property(self, "modulate", Color(1, 1, 1, 1), 0.25).set_ease(Tween.EASE_OUT)


func _physics_process(_delta: float) -> void:
	since_last_frame = since_last_frame + 1.0
	if Saves.get_or_return("settings", "show_debug", false):
		$MieuPeer/RichTextLabel.text = "[center]" + player_name + "[/center]\n Networking tween value: " + str(StabilityMitigator.get_mitigation(id))


func sign_adoption(identity: String) -> void:
	id = identity
	player_name = SteamLobbies.lobby_members[id]["steam_name"]
	$MieuPeer/RichTextLabel.text = "[center]" + player_name + "[/center]"


func move_to(new_position: Vector2, sprite_y: float, movement_id: int, frame: int = -1) -> void:
	if is_visible_in_tree():
		new_position = new_position.clamp(Vector2(0,0), Vector2(1920, 1080))
		StabilityMitigator.add_mitigation_data(id, movement_id, since_last_frame)
		create_tween().tween_property(self, "global_position", new_position, GlobalVars.frame * StabilityMitigator.get_mitigation(id))
		create_tween().tween_property($MieuPeer, "position", Vector2($MieuPeer.position.x, sprite_y), GlobalVars.frame * StabilityMitigator.get_mitigation(id))
		if $MieuPeer.position.y <= GlobalVars.sprite_offset.y:
			$Shadow.scale = Vector2(.5, .25) * (($MieuPeer.position.y - GlobalVars.sprite_offset.y)/300.0 + 1)
		elif $Shadow.scale != Vector2(.5, .25):
			$Shadow.scale = Vector2(.5, .25)
		
		if frame != -1:
			set_frame(frame)
		
		since_last_frame = 0.0


func set_frame(frame: int) -> void:
	$Shadow.frame = frame
	$MieuPeer.frame = frame


func remove() -> void:
	if StabilityMitigator.players.has(id):
		StabilityMitigator.players[id]["movement_id"] = -1
	if P2P.kitties.has(id):
		P2P.kitties[id] = null
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.15).set_ease(Tween.EASE_OUT)
	await tween.finished
	queue_free()
