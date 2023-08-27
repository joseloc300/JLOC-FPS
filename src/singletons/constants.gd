extends Node

# Enums
enum TEAMS { NO_TEAM, BLUE, RED}
enum PLAYER_STATE { NOT_RDY, RDY, EDIT_LOADOUT, IN_GAME }
enum OBJECTIVE_TYPE { N_KILLS, N_ROUNDS }

var GAME_MODES
var MAPS
var WEAPONS

func _ready():
	pass
#	load_jsons()
#
#func load_jsons():
#	var file = FileAccess.open("res://data/game_modes.json", FileAccess.READ)
#	var test_json_conv = JSON.new()
#	test_json_conv.parse(file.get_as_text())
#	GAME_MODES = test_json_conv.get_data()
#	file.close()
#
#	file.open("res://data/maps.json", FileAccess.READ)
#	test_json_conv = JSON.new()
#	test_json_conv.parse(file.get_as_text())
#	MAPS = test_json_conv.get_data()
#	file.close()
#
#	file.open("res://data/weapons.json", FileAccess.READ)
#	test_json_conv = JSON.new()
#	test_json_conv.parse(file.get_as_text())
#	WEAPONS = test_json_conv.get_data()
#	file.close()
