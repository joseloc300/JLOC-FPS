extends CharacterBody3D

var camera
var rotation_helper

var MOUSE_SENSITIVITY = 0.05

const MAX_SPRINT_SPEED = 8
const SPRINT_ACCEL = 12
var is_sprinting = false

# change to test different teams
var team = Constants.BLUE_TEAM

var current_weapon_idx = 0
var last_weapon_idx = 0
var weapons = [null, null, null]

# not related to var above
var last_slave_current_weapon_idx = 0

const PRIMARY_WEAPON = 0
const SECONDARY_WEAPON = 1
const MELEE_WEAPON = 2

const skin_default = preload("res://characters/scenes/char_model_default.tscn")
const skin_blue = preload("res://characters/scenes/char_model_blue.tscn")
const skin_red = preload("res://characters/scenes/char_model_red.tscn")

func _ready():
	camera = $RotationHelper/Camera3D
	rotation_helper = $RotationHelper
	
	init()	
	set_weapon_raycasts_position()


func init():	
	if team == Constants.NO_TEAM:
			var model_instance_default = preload("res://characters/scenes/char_model_default.tscn").instantiate()
			$RotationHelper/Model.add_child(model_instance_default)
	elif team == Constants.BLUE_TEAM:
			var model_instance_blue = preload("res://characters/scenes/char_model_blue.tscn").instantiate()
			$RotationHelper/Model.add_child(model_instance_blue)
	elif team == Constants.RED_TEAM:
			var model_instance_red = preload("res://characters/scenes/char_model_red.tscn").instantiate()
			$RotationHelper/Model.add_child(model_instance_red)


func process_input(delta):
	pass

@rpc("any_peer") func receive_damage(enemy_id, value):
	print_debug("damage = " + str(value))

func set_weapon_raycasts_position():
	var current_weapon = $RotationHelper/Camera3D/Weapons.get_child(current_weapon_idx).get_child(0)
	var camera_global_transform = $RotationHelper/Camera3D.global_transform
	current_weapon.set_raycasts_position(camera_global_transform)


func switch_weapon(new_weapon_idx):
	if new_weapon_idx != current_weapon_idx:
		last_weapon_idx = current_weapon_idx
		current_weapon_idx = new_weapon_idx
		
		for weapon in weapons:
			weapon.visible = false
		
		weapons[new_weapon_idx].visible = true


func set_weapon(primary, secondary, melee):
	if primary != null:
		var p_instance = primary.instantiate()
		$RotationHelper/Camera3D/Weapons/Primary.get_child(0).queue_free()
		$RotationHelper/Camera3D/Weapons/Primary.add_child(p_instance)
		weapons[PRIMARY_WEAPON] = p_instance
	if secondary != null:
		var s_instance = secondary.instantiate()
		$RotationHelper/Camera3D/Weapons/Secondary.get_child(0).queue_free()
		$RotationHelper/Camera3D/Weapons/Secondary.add_child(s_instance)
		weapons[SECONDARY_WEAPON] = s_instance
	if melee != null:
		var m_instance = melee.instantiate()
		$RotationHelper/Camera3D/Weapons/Melee.get_child(0).queue_free()
		$RotationHelper/Camera3D/Weapons/Melee.add_child(m_instance)
		weapons[MELEE_WEAPON] = m_instance


func _on_ShootTimer_timeout():
	var current_weapon = $RotationHelper/Camera3D/Weapons.get_child(current_weapon_idx).get_child(0)
	current_weapon.shoot(team, -3)
