extends Control

func _on_BtnHost_pressed():
	$Host.visible = true
	$Main.visible = false


func _on_BtnJoin_pressed():
	$Join.visible = true
	$Main.visible = false


func _on_BtnCreateLobby_pressed():
	if not $Host/Port.text.is_valid_int():
		$Popups/ConnectionError.dialog_text = "ERROR: Invalid Port"
		$Popups/ConnectionError.popup()
		return
	
	var server_port = int($Host/Port.text)
	var max_players = $Host/MaxPlayers.value
	var nickname = $PlayerNickname.text
	var error_code = NetworkManager.host_server(server_port, max_players, nickname)
	if error_code == ERR_CANT_CREATE:
		$Popups/ConnectionError.dialog_text = "ERROR: Can't create server"
		$Popups/ConnectionError.popup()
		return
	elif error_code == ERR_ALREADY_IN_USE:
		$Popups/ConnectionError.dialog_text = "ERROR: Connection already in use"
		$Popups/ConnectionError.popup()
		return
	
	var error_code_scene = get_tree().change_scene_to_file("res://src/menus/lobby/lobby.tscn")


func _on_BtnBack_Host_pressed():
	$Host.visible = false
	$Main.visible = true


func _on_BtnJoinLobby_pressed():
	var server_address = $Join/ServerAddress.text
	
	if not $Join/Port.text.is_valid_int():
		$Popups/ConnectionError.dialog_text = "ERROR: Invalid Port"
		$Popups/ConnectionError.popup()
		return
	
	var server_port = int($Join/Port.text)
	var nickname = $PlayerNickname.text
	var error_code = NetworkManager.join_server(server_address, server_port, nickname)
	if error_code == ERR_CANT_CREATE:
		$Popups/ConnectionError.dialog_text = "ERROR: Can't join server"
		$Popups/ConnectionError.popup()
		return
	elif error_code == ERR_ALREADY_IN_USE:
		$Popups/ConnectionError.dialog_text = "ERROR: Connection already in use"
		$Popups/ConnectionError.popup()
		return
	
	var error_code_scene = get_tree().change_scene_to_file("res://src/menus/lobby/lobby.tscn")


func _on_BtnBack_Join_pressed():
	$Join.visible = false
	$Main.visible = true


func _on_BtnExit_pressed():
	get_tree().quit(0)
