extends Node

const GAME_MODE_NAME = "FFA"
const GAME_END_BANNER_TIME = 5

const OBJECTIVE_VALUES = [15, 30, 45]
var curr_objetive_value = 0

var leader_id

var players_info = {}

var kill_events = []

# Called when the node enters the scene tree for the first time.
func _ready():
	$GameTimer.start(5 * 60)
	populate_player_info()

#func _physics_process(delta):
#	pass

func set_objective_value(objective_value):
	curr_objetive_value = objective_value

func populate_player_info():
	var self_info = NetworkManager.get_my_info()
	var self_id = get_tree().get_multiplayer().get_unique_id()
	var self_player_info = {
		"nickname": self_info["nickname"],
		"team": self_info["team"],
		"kills": 0,
		"deaths": 0
	}
	players_info[self_id] = self_player_info
	
	
	var other_player_ids = NetworkManager.player_info.keys()
	var other_players_info = NetworkManager.player_info.values()
	for i in range(other_players_info.size()):
		var p_id = other_player_ids[i]
		var p_info = other_players_info[i]
	
		var new_player_info = {
			"nickname": p_info["nickname"],
			"team": p_info["team"],
			"kills": 0,
			"deaths": 0
		}
		players_info[p_id] = new_player_info

func score_player_kill(killer_id, victim_id):
	players_info[victim_id]["deaths"] += 1
	if killer_id != victim_id:
		players_info[killer_id]["kills"] += 1
	
	var new_kill_event = {
		"killer_id": killer_id,
		"victim_id": victim_id,
		"killer": players_info[killer_id]["nickname"],
		"victim": players_info[victim_id]["nickname"]
	}
	
	kill_events.append(new_kill_event)


func _on_GameTimer_timeout():
	$GameEndBannerTimer.start(GAME_END_BANNER_TIME)


func _on_GameEndBannerTimer_timeout():
	if multiplayer.is_server():
		NetworkManager.return_to_lobby()
