extends Control

@onready var game_mode_node = get_node("/root/GameSceneMP/GameMode").get_child(0)

#font para depois. n sei se é assim
#onready var dyn_font_32 = load("res://fonts/Staatliches/dyn_font_32.tres")
const HUD_UPDATE_RATE = 1

var idToNode = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	$Scoreboard/GridContainer.columns = 4
	populate_scoreboard()

func _process(delta):
	if Input.is_action_just_pressed("show_scoreboard"):
		$Scoreboard.visible = true
	elif Input.is_action_just_released("show_scoreboard"):
		$Scoreboard.visible = false


func _on_UpdateHUDTimer_timeout():
	$TimeRemainingLabel.text = "TIME\n" + str(int(game_mode_node.get_node("./GameTimer").time_left))
	
	var curr_event = game_mode_node.kill_events.pop_front()
	while curr_event != null:
		var event_text = curr_event["killer"] + "  KILLED  " + curr_event["victim"]
		
		idToNode[curr_event["victim_id"]]["deaths_label"].text = str(int(idToNode[curr_event["victim_id"]]["deaths_label"].text) + 1)
		if curr_event["killer_id"] != curr_event["victim_id"]:
			idToNode[curr_event["killer_id"]]["kills_label"].text = str(int(idToNode[curr_event["killer_id"]]["kills_label"].text) + 1)
		
		curr_event = game_mode_node.kill_events.pop_front()


func populate_scoreboard():
	#titles
	var label_0 = Label.new()
	label_0.text = "Nickname"
	$Scoreboard/GridContainer.add_child(label_0)
	
	var label_1 = Label.new()
	label_1.text = "Team"
	$Scoreboard/GridContainer.add_child(label_1)
	
	var label_2 = Label.new()
	label_2.text = "Kills"
	$Scoreboard/GridContainer.add_child(label_2)
	
	var label_3 = Label.new()
	label_3.text = "Deaths"
	$Scoreboard/GridContainer.add_child(label_3)
	
#	var self_id = get_tree().get_multiplayer().get_unique_id()
#	var self_info = NetworkManager.get_my_info()
#	#self stats
#	var self_nickname_label = Label.new()
#	self_nickname_label.text = self_info["nickname"]
#	$Scoreboard/GridContainer.add_child(self_nickname_label)
#
#	#team
#	var self_team_label = Label.new()
#	if self_info["team"] == Constants.TEAMS.BLUE:
#		self_team_label.text = "BLUE"
#	elif self_info["team"] == Constants.TEAMS.RED:
#		self_team_label.text = "RED"
#	$Scoreboard/GridContainer.add_child(self_team_label)
#
#	#kills
#	var self_kills_label = Label.new()
#	self_kills_label.text = "0"
#	$Scoreboard/GridContainer.add_child(self_kills_label)
#
#	#deaths
#	var self_deaths_label = Label.new()
#	self_deaths_label.text = "0"
#	$Scoreboard/GridContainer.add_child(self_deaths_label)
#
#	var selfIdToNode = {
#		"kills_label": self_kills_label,
#		"deaths_label": self_deaths_label
#	}
#
#	idToNode[self_id] = selfIdToNode
	
	var player_ids = NetworkManager.player_info.keys()
	var players_info = NetworkManager.player_info.values()
	for i in range(players_info.size()):
		var p_id = player_ids[i]
		var p_info = players_info[i]
		#nickname
		var nickname_label = Label.new()
		nickname_label.text = p_info["nickname"]
		$Scoreboard/GridContainer.add_child(nickname_label)
		
		#team
		var team_label = Label.new()
		if p_info["team"] == Constants.TEAMS.BLUE:
			team_label.text = "BLUE"
		elif p_info["team"] == Constants.TEAMS.RED:
			team_label.text = "RED"
		$Scoreboard/GridContainer.add_child(team_label)
		
		#kills
		var kills_label = Label.new()
		kills_label.text = "0"
		$Scoreboard/GridContainer.add_child(kills_label)
		
		#deaths
		var deaths_label = Label.new()
		deaths_label.text = "0"
		$Scoreboard/GridContainer.add_child(deaths_label)
		
		var newIdToNode = {
			"kills_label": kills_label,
			"deaths_label": deaths_label
		}
		
		idToNode[p_id] = newIdToNode
