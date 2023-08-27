extends Control

const LOG_CREATE = 0
const LOG_JOIN = 1
const LOG_LEAVE = 2
const LOG_BLUE = 3
const LOG_RED = 4

var isReady = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if multiplayer.is_server():
		$TeamMapSelector/Buttons/BtnStartGame.visible = true
	else:
		$TeamMapSelector/Buttons/BtnReady.visible = true
	
	setup_gamemode_map_options()


func update_log(player_id, log_type):
	var nickname
	
	if player_id == get_tree().get_unique_id():
		nickname = NetworkManager.my_info["nickname"]
	else:
		nickname = NetworkManager.player_info[player_id]["nickname"]
	
	if log_type == 0:
		$Log/Content.text += nickname + " created the lobby.\n"
	if log_type == 1:
		$Log/Content.text += nickname + " joined the lobby.\n"
	if log_type == 2:
		$Log/Content.text += nickname + " left the lobby.\n"
	if log_type == 3:
		$Log/Content.text += nickname + " switched to the blue team.\n"
	if log_type == 4:
		$Log/Content.text += nickname + " switched to the red team.\n"


func _on_BtnLeaveLobby_pressed():
	NetworkManager.disconnect_server()
	get_tree().change_scene_to_file("res://src/menus/main_menu/main_menu.tscn")


func _on_BtnStartGame_pressed():
	NetworkManager.start_game()


func _on_BtnBlue_pressed():
	NetworkManager.set_my_team(Constants.TEAMS.BLUE)


func _on_BtnRed_pressed():
	NetworkManager.set_my_team(Constants.TEAMS.RED)


func _on_BtnReady_pressed():
	$TeamMapSelector/Buttons/BtnReady.visible = false
	$TeamMapSelector/Buttons/BtnUnready.visible = true
	$TeamMapSelector/Buttons/BtnEditLoadout.disabled = true
	$TeamMapSelector/Buttons/BtnLeaveLobby.disabled = true


func _on_BtnUnready_pressed():
	$TeamMapSelector/Buttons/BtnReady.visible = true
	$TeamMapSelector/Buttons/BtnUnready.visible = false
	$TeamMapSelector/Buttons/BtnEditLoadout.disabled = false
	$TeamMapSelector/Buttons/BtnLeaveLobby.disabled = false


func _on_BtnEditLoadout_pressed():
	$TeamMapSelector.visible = false
	$LoadoutManager.visible = true


func _on_BtnLoadoutManagerBack_pressed():
	$TeamMapSelector.visible = true
	$LoadoutManager.visible = false


func _on_TimerUpdateTeams_timeout():
	var red_team = ""
	var blue_team = ""
	
	for p_id in NetworkManager.player_info:
		var p_info = NetworkManager.player_info[p_id]
		if p_info.team == Constants.TEAMS.BLUE:
			blue_team += p_info.nickname + "\n"
		elif p_info.team == Constants.TEAMS.RED:
			red_team += p_info.nickname + "\n"
	
	$TeamMapSelector/BlueTeam/Players.text = blue_team
	$TeamMapSelector/RedTeam/Players.text = red_team


func _on_ChatMessage_text_entered(new_text):
	var message = "[color=yellow]" + NetworkManager.my_info["nickname"] + \
	":[/color] " +  new_text + "\n"
	rpc("add_chat_message", message)
	$TeamMapSelector/Chat/ChatMessage.text = ""


@rpc("any_peer", "call_local") func add_chat_message(message):
	$TeamMapSelector/Chat/ChatText.append_bbcode(message)


func _on_OptionGameMode_item_selected(index):
	pass # Replace with function body.


func _on_OptionMap_item_selected(index):
	pass # Replace with function body.


func setup_gamemode_map_options():
	pass
#	for id in Constants.GAME_MODES:
#		var gamemode = Constants.GAME_MODES[id]
#		$TeamMapSelector/MapModeSelector/OptionGameMode.add_item(gamemode.name, id)
#
#	for id in Constants.MAPS:
#		var name = Constants.MAPS[id]
#		$TeamMapSelector/MapModeSelector/OptionMap.add_item(name, id)


func _on_btn_start_game_pressed():
	NetworkManager.start_game()
