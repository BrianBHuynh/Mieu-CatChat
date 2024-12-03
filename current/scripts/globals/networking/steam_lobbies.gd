extends Node

var lobby_data
var lobby_id: int = 0
var lobby_members: Array = []
var lobby_members_max: int = 10
var lobby_vote_kick: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Steam.join_requested.connect(_on_lobby_join_requested)
	#Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	Steam.lobby_created.connect(_on_lobby_created)
	#Steam.lobby_data_update.connect(_on_lobby_data_update)
	#Steam.lobby_invite.connect(_on_lobby_invite)
	#Steam.lobby_joined.connect(_on_lobby_joined)
	#Steam.lobby_match_list.connect(_on_lobby_match_list)
	#Steam.lobby_message.connect(_on_lobby_message)
	#Steam.persona_state_change.connect(_on_persona_change)
	check_command_line()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func check_command_line() -> void:
	var command_line: Array = OS.get_cmdline_args()
	if command_line.size() > 0 && command_line[0] == "+connect_lobby" && command_line[1] > 0:
		print("Command line lobby ID: %s" % command_line[1])
		#join_lobby(int(command_line[1]))

func create_lobby(type: int) -> void:
	if lobby_id == 0:
		Steam.createLobby(type, lobby_members_max)

func _on_lobby_created(_connected: int, this_lobby_id: int) -> void:
	lobby_id = this_lobby_id
	print("Created a lobby: %s" % lobby_id)
	Steam.setLobbyJoinable(lobby_id, true)
	Steam.setLobbyData(lobby_id, "name", "Gramps' Lobby")
	Steam.setLobbyData(lobby_id, "mode", "GodotSteam test")
	var set_relay: bool = Steam.allowP2PPacketRelay(true)
	print("Allowing Steam to be relay backup: %s" % set_relay)

func _on_open_lobby_list_pressed() -> void:
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	print("Requesting a lobby list")
	Steam.requestLobbyList()
