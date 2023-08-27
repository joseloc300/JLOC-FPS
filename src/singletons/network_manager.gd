extends Node

# These signals can be connected to by a UI lobby scene or the game scene.
# unused for now. from networking example in docs
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const DEFAULT_PLAYER_INFO = {
	nickname = "",
	team = Constants.TEAMS.NO_TEAM,
	is_host = false,
	state = Constants.PLAYER_STATE.NOT_RDY,
	primary_weapon = 1,
	secondary_weapon = 1,
	melee_weapon = 1
}

# Player info, associate ID to data
var player_info = {}

# Info we send to other players


var my_network_id: int


# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _on_player_connected(id):
	# Called on both clients and server when a peer connects. Send my info to it.
	_register_player.rpc_id(id, player_info[my_network_id])
	print("player " + str(id) + " connected")
	# rpc_id(id, "register_player", )


func _on_player_disconnected(id):
	print("player " + str(id) + " disconnected")
	player_info.erase(id) # Erase player from info.


func _on_connected_ok():
	print("test test test")


func _on_server_disconnected():
#	Server kicked us; show error and abort.
	get_tree().change_scene_to_file("res://src/menus/main_menu/main_menu.tscn")


func _on_connected_fail():
	pass # Could not even connect to server; abort.


func get_my_info():
	return  player_info[my_network_id]


func set_my_team(team):
#	player_info[my_network_id]["team"] = team
#	player_info[my_network_id].merge({"team": team}, true)
	player_info[my_network_id]["team"] = team
	update_other_player_info.rpc(player_info[my_network_id])


@rpc("any_peer")
func update_other_player_info(info):
	# Get the id of the RPC sender.
	var id = multiplayer.get_remote_sender_id()
	# Store the info
#	player_info[id] = info
	player_info.merge({id: info}, true) 


func host_server(server_port, max_players, nickname):
	var peer = ENetMultiplayerPeer.new()

	var error_code = peer.create_server(server_port, max_players)
	if error_code:
		return error_code
		
#	get_tree().network_peer = peer
	multiplayer.multiplayer_peer = peer
	my_network_id = multiplayer.get_unique_id()
	
#	player_info[my_network_id] = DEFAULT_PLAYER_INFO
	player_info.merge({my_network_id: DEFAULT_PLAYER_INFO.duplicate(true)}, true) 
	
	player_info[my_network_id]["nickname"] = nickname
	player_info[my_network_id]["is_host"] = true
	player_info[my_network_id]["state"] = Constants.PLAYER_STATE.NOT_RDY
	return error_code


func join_server(server_address, server_port, nickname):
	var peer = ENetMultiplayerPeer.new()
	var error_code = peer.create_client(server_address, server_port)
	if error_code:
		return error_code
	
	multiplayer.multiplayer_peer = peer
	my_network_id = multiplayer.get_unique_id()
	
#	player_info[my_network_id] = DEFAULT_PLAYER_INFO
	player_info.merge({my_network_id: DEFAULT_PLAYER_INFO.duplicate(true)}, true) 
	
	player_info[my_network_id]["nickname"] = nickname
	player_info[my_network_id]["state"] = Constants.PLAYER_STATE.NOT_RDY
	return error_code


func disconnect_server():
	# TODO - send update to other players
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null


@rpc("any_peer", "call_local", "reliable")
func _register_player(info):
	# Get the id of the RPC sender.
	var id = multiplayer.get_remote_sender_id()
	# Store the info
#	player_info[id] = info
	player_info.merge({id: info}, true) 

	# Call function to update lobby UI here
	print(get_tree().current_scene.name)
	# if get_tree().current_scene.name == "game":


func start_game():
	load_scene.rpc()

func done_loading():
	ask_for_preconfigure.rpc_id(1)


@rpc("any_peer", "call_local")
func load_scene():
	get_tree().change_scene_to_file("res://src/maps/common/game_scene_mp.tscn")


@rpc("any_peer", "reliable")
func ask_for_preconfigure():
	var who = multiplayer.get_remote_sender_id()
	pre_configure_game.rpc_id(who)


@rpc("any_peer", "reliable")
func pre_configure_game():
	var selfPeerID = multiplayer.get_unique_id()

	# Load world
	#var world = load(which_level).instance()
	#get_node("/root").add_child(world)

	# Load my player
	var my_player = preload("res://src/characters/player.tscn").instantiate()
	my_player.set_name("Player_" + str(selfPeerID))
	my_player.set_multiplayer_authority(selfPeerID, true) # Will be explained later
	get_node("/root/GameSceneMP/GameCoordinator/Players").add_child(my_player)
	my_player.init(player_info[my_network_id])

	# Load other players
	for p_key in player_info.keys():
		if p_key == multiplayer.get_unique_id():
			continue
		
		var p = player_info[p_key]
		var player = preload("res://src/characters/player.tscn").instantiate()
		player.set_name("Player_" + str(p_key))
		player.set_multiplayer_authority(p_key, true) # Will be explained later
		get_node("/root/GameSceneMP/GameCoordinator/Players").add_child(player)
		player.init(player_info[p_key])

	get_node("/root/GameSceneMP/GameCoordinator").update_player_node_refs()

	# Tell server (remember, server is always ID=1) that this peer is done pre-configuring.
	# The server can call get_tree().get_rpc_sender_id() to find out who said they were done.
	# rpc_id(1, "done_preconfiguring")


func return_to_lobby():
	send_all_to_lobby.rpc()


@rpc("any_peer", "call_local")
func send_all_to_lobby():
	get_tree().change_scene_to_file("res://src/menus/lobby/lobby.tscn")


#func damage_player(player_id, damage):
#	var self_id = get_tree().get_network_unique_id()
#	rpc_id(player_id, "receive_damage_packet", self_id, damage)


@rpc("any_peer", "call_local")
func update_player_death(killer_id, victim_id):
	var game_mode_node = get_node("/root/GameSceneMP/GameMode").get_child(0)
	game_mode_node.score_player_kill(killer_id, victim_id)


func send_player_death_packet(killer_id, victim_id):
	update_player_death.rpc(killer_id, victim_id)


#remote func receive_damage_packet(enemy_id, damage):
#	var self_peer_id = get_tree().get_network_unique_id()
#	var player_node = get_node("/root/GameSceneMP/GameCoordinator/Players/Player_" + str(self_peer_id))
#	player_node.receive_damage(enemy_id, damage)

func update_player_weapons_local(primary_id, secondary_id, melee_id):
	if primary_id != null:
		player_info[my_network_id]["primary_weapon"] = primary_id
	if secondary_id != null:
		player_info[my_network_id]["secondary_weapon"] = secondary_id
	if melee_id != null:
		player_info[my_network_id]["melee_weapon"] = melee_id
	
	var packet = {
		"player_id": my_network_id,
		"primary_id": primary_id,
		"secondary_id": secondary_id,
		"melee_id": melee_id
	}
	
	update_player_weapons.rpc(packet)
	

@rpc("any_peer")
func update_player_weapons(packet):
	var player_id = packet["player_id"]
	if packet["primary_id"] != null:
		player_info[player_id]["primary_weapon"] = packet["primary_id"]
	if packet["secondary_id"] != null:
		player_info[player_id]["secondary_weapon"] = packet["secondary_id"]
	if packet["melee_id"] != null:
		player_info[player_id]["melee_weapon"] = packet["melee_id"]
	
