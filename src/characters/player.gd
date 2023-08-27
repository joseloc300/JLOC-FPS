extends CharacterBody3D

const GRAVITY = -24.8
var vel = Vector3()
const MAX_SPEED = 5
const JUMP_SPEED = 8
const ACCEL = 7

var dir = Vector3()

var old_transform = Transform3D()

const DEACCEL= 12
const MAX_SLOPE_ANGLE = 40

var camera
var rotation_helper

var MOUSE_SENSITIVITY = 0.05

const MAX_SPRINT_SPEED = 8
const SPRINT_ACCEL = 12
var is_sprinting = false

var team = -1

var hp = 100
var alive = true
var current_weapon_idx = 0
var last_weapon_idx = 0
var weapons = [null, null, null]

var raw_rotation_helper_degrees
#var acummulated_recoil_impulse = 0
#var recoil_degrees = 0

# not related to var above
var last_slave_current_weapon_idx = 0
var immune = false
var was_walking = false

var slave_transform = Transform3D()
var slave_movement = Vector3()
var slave_alive = true
var slave_current_weapon_idx = 0

const PRIMARY_WEAPON = 0
const SECONDARY_WEAPON = 1
const MELEE_WEAPON = 2

const HEAD_MUL = 5.0
const BODY_MUL = 1.0
const MEMBER_MUL = 0.75

const skin_default = preload("res://src/characters/char_model_default.tscn")
const skin_blue = preload("res://src/characters/char_model_blue.tscn")
const skin_red = preload("res://src/characters/char_model_red.tscn")

var game_coordinator_node

func _ready():
	camera = $RotationHelper/Camera3D
	rotation_helper = $RotationHelper
	raw_rotation_helper_degrees = rotation_helper.rotation_degrees
	
	var spawn = get_node("/root/GameSceneMP/Map").get_child(0).get_random_spawn_point()
	transform = spawn.transform
	
	if is_multiplayer_authority():
		set_weapon_raycasts_position()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$RotationHelper/Camera3D.current = true
		$HUD.visible = true
		$Timers/NetworkSendRate.start(0.05)
		
		game_coordinator_node = find_parent("GameCoordinator")


func init(player_info):
	$GUI3D/SubViewport/Label.text = player_info["nickname"]
	
	team = player_info["team"]
	if team == Constants.TEAMS.NO_TEAM:
			var model_instance_default = skin_default.instantiate()
			$RotationHelper/Model.add_child(model_instance_default)
	elif team == Constants.TEAMS.BLUE:
			var model_instance_blue = skin_blue.instantiate()
			$RotationHelper/Model.add_child(model_instance_blue)
	elif team == Constants.TEAMS.RED:
			var model_instance_red = skin_red.instantiate()
			$RotationHelper/Model.add_child(model_instance_red)
	
#	var primary_weapon = WeaponFactory.primary_weapons_objs[player_info.primary_weapon]
#	var secondary_weapon = WeaponFactory.primary_weapons_objs[player_info.secondary_weapon]
#	var melee_weapon = WeaponFactory.primary_weapons_objs[player_info.melee_weapon]
	


func _physics_process(delta):
	non_master_update(delta)
	process_input(delta)
	process_movement(delta)


func non_master_update(delta):
	if is_multiplayer_authority():
		return
	
	if slave_current_weapon_idx == PRIMARY_WEAPON and last_slave_current_weapon_idx != PRIMARY_WEAPON:
		last_slave_current_weapon_idx = slave_current_weapon_idx
		$RotationHelper/Camera3D/Weapons/Primary.visible = true
		$RotationHelper/Camera3D/Weapons/Secondary.visible = false
		$RotationHelper/Camera3D/Weapons/Melee.visible = false
	
	if slave_current_weapon_idx == SECONDARY_WEAPON and last_slave_current_weapon_idx != SECONDARY_WEAPON:
		last_slave_current_weapon_idx = slave_current_weapon_idx
		$RotationHelper/Camera3D/Weapons/Primary.visible = false
		$RotationHelper/Camera3D/Weapons/Secondary.visible = true
		$RotationHelper/Camera3D/Weapons/Melee.visible = false
	
	if slave_current_weapon_idx == MELEE_WEAPON and last_slave_current_weapon_idx != MELEE_WEAPON:
		last_slave_current_weapon_idx = slave_current_weapon_idx
		$RotationHelper/Camera3D/Weapons/Primary.visible = false
		$RotationHelper/Camera3D/Weapons/Secondary.visible = false
		$RotationHelper/Camera3D/Weapons/Melee.visible = true
	
	if (slave_movement.x != 0.0 or slave_movement.z != 0.0) and not was_walking:
		was_walking = true
#		$SFXFootstepsOthers.play()
	
	if slave_movement.x == 0.0 and slave_movement.z == 0.0 and was_walking:
		was_walking = false
#		$SFXFootstepsOthers.stop()
	
	if not slave_alive:
		visible = false
		$Collisions/AreaHead/CollisionHead.disabled = true
		$Collisions/AreaBody/CollisionBody.disabled = true
	else:
		visible = true
		$Collisions/AreaHead/CollisionHead.disabled = false
		$Collisions/AreaBody/CollisionBody.disabled = false

# TODO need anotations?
@rpc
func update_this_other_clients(id, new_transform, new_vel, new_alive, new_current_weapon_idx):
	if get_multiplayer_authority() != id:
		return
		
	# TODO improve this
	if new_transform != null:
		slave_transform = new_transform
	if new_vel != null:
		slave_movement = new_vel
	if new_alive != null:
		slave_alive = new_alive
	if new_current_weapon_idx != null:
		slave_current_weapon_idx = new_current_weapon_idx

func process_input(delta):
	if not is_multiplayer_authority():
		return
	
	if not alive:
		return
	
	var current_weapon = $RotationHelper/Camera3D/Weapons.get_child(current_weapon_idx).get_child(0)
	
	# TODO: move to function
	$HUD/Ammo.text = "Ammo: " + str(current_weapon.curr_ammo_mag) + " / " + str(current_weapon.curr_ammo_reserve)
	
	# TODO: create function
#	recoil_degrees = current_weapon.max_recoil_degrees * (1 - 1 / (1 +  acummulated_recoil_impulse) )
#	var camera_rot = raw_rotation_helper_degrees
#	camera_rot.x = clamp(camera_rot.x + recoil_degrees, -70, 70)
#	rotation_helper.rotation_degrees = camera_rot
	
	
	var is_firing = current_weapon.is_firing
	if Input.is_action_pressed("shoot") and not Input.is_action_pressed("movement_sprint") and current_weapon.can_shoot():
		var targets_dmg = current_weapon.shoot(team, multiplayer.get_unique_id())
#		acummulated_recoil_impulse += current_weapon.recoil_impulse
		if not targets_dmg.is_empty():
			$Sound/SFXHitEnemy.play()
			for idx in range(targets_dmg.keys().size()):
	#			var target_id = targets_dmg.keys()[idx]
	#			var damage_to_target = targets_dmg[target_id]
	#			NetworkManager.damage_player(target_id, damage_to_target)
				var target_id = targets_dmg.keys()[idx]
				var damage_to_target = targets_dmg[target_id]["damage"]
				game_coordinator_node.damage_player(damage_to_target, multiplayer.get_unique_id(), target_id)
#				rpc_id(target_id, "receive_damage", get_tree().get_network_unique_id(), damage_to_target)
#	else:
#		var final_recoil_drop = current_weapon.recoil_drop * delta
#		if not current_weapon.is_firing:
#			final_recoil_drop *= 2
#		acummulated_recoil_impulse -= final_recoil_drop
#		acummulated_recoil_impulse = max(0, acummulated_recoil_impulse)
	
	# ----------------------------------
	# Select Weapon
	if Input.is_action_pressed("primary_weapon") and current_weapon_idx != PRIMARY_WEAPON:
		current_weapon.holdster()
		current_weapon_idx = PRIMARY_WEAPON
		set_weapon_raycasts_position()
		
		update_this_other_clients.rpc(multiplayer.get_unique_id(), null, null, null, current_weapon_idx)
#		rset("slave_current_weapon_idx", current_weapon_idx)
		
		$RotationHelper/Camera3D/Weapons/Primary.visible = true
		$RotationHelper/Camera3D/Weapons/Secondary.visible = false
		$RotationHelper/Camera3D/Weapons/Melee.visible = false
	if Input.is_action_pressed("secondary_weapon") and current_weapon_idx != SECONDARY_WEAPON:
		current_weapon.holdster()
		current_weapon_idx = SECONDARY_WEAPON
		set_weapon_raycasts_position()
		
		update_this_other_clients.rpc(multiplayer.get_unique_id(), null, null, null, current_weapon_idx)
#		rset("slave_current_weapon_idx", current_weapon_idx)
		
		$RotationHelper/Camera3D/Weapons/Primary.visible = false
		$RotationHelper/Camera3D/Weapons/Secondary.visible = true
		$RotationHelper/Camera3D/Weapons/Melee.visible = false
	if Input.is_action_pressed("melee_weapon") and current_weapon_idx != MELEE_WEAPON:
		current_weapon.holdster()
		current_weapon_idx = MELEE_WEAPON
		set_weapon_raycasts_position()
		
		update_this_other_clients.rpc(multiplayer.get_unique_id(), null, null, null, current_weapon_idx)
#		rset("slave_current_weapon_idx", current_weapon_idx)
		
		$RotationHelper/Camera3D/Weapons/Primary.visible = false
		$RotationHelper/Camera3D/Weapons/Secondary.visible = false
		$RotationHelper/Camera3D/Weapons/Melee.visible = true
	
	
	if Input.is_action_just_pressed("weapon_quickswitch"):
		pass
	
	if Input.is_action_just_pressed("reload") and current_weapon.can_reload():
		current_weapon.reload()
	
	# ----------------------------------
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1

	input_movement_vector = input_movement_vector.normalized()

	# Basis vectors are already normalized.
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	# ----------------------------------

	# ----------------------------------
	# Jumping
	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			vel.y = JUMP_SPEED
	# ----------------------------------

	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# ----------------------------------
	
	# ----------------------------------
	# Sprinting
	if Input.is_action_pressed("movement_sprint"):
		is_sprinting = true
	else:
		is_sprinting = false
	# ----------------------------------


func process_movement(delta):
	if not is_multiplayer_authority():
		if old_transform != slave_transform:
			transform = slave_transform
			old_transform = slave_transform
		set_velocity(slave_movement)
		move_and_slide()
		return
	
	dir.y = 0
	dir = dir.normalized()

	vel.y += delta * GRAVITY

	var hvel = vel
	hvel.y = 0

	var target = dir
	if is_sprinting:
		target *= MAX_SPRINT_SPEED
	else:
		target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		if is_sprinting:
			accel = SPRINT_ACCEL
		else:
			accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.lerp(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	
	#old netcode
	#rset_unreliable("slave_transform", transform)
	#rset("slave_movement", vel)
	
	if (vel.x != 0.0 or vel.z != 0.0) and not was_walking:
		was_walking = true
#		$SFXFootsteps.play()
	
	if vel.x == 0.0 and vel.z == 0 and was_walking:
		was_walking = false
#		$SFXFootsteps.stop()
	
	set_velocity(vel)
	set_up_direction(Vector3(0, 1, 0))
	set_floor_stop_on_slope_enabled(0.05)
	set_max_slides(4)
	set_floor_max_angle(deg_to_rad(MAX_SLOPE_ANGLE))
	move_and_slide()
	vel = velocity

func _input(event):
	if not is_multiplayer_authority():
		return
	
	if not alive:
		return
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
#		raw_rotation_helper_degrees.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		rotation_helper.rotation_degrees = raw_rotation_helper_degrees
		rotation_helper.rotate_x(deg_to_rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * -1))



		var camera_rot = rotation_helper.rotation_degrees
		raw_rotation_helper_degrees = camera_rot
#		camera_rot.x = clamp(camera_rot.x + recoil_degrees, -70, 70)
		rotation_helper.rotation_degrees = camera_rot


@rpc("any_peer")
func receive_damage(damage, idSource):
	if immune:
		return
	
	hp -= damage
	$Sound/SFXHit.play()
	#TODO criar funçao q atualize hp e label ao msm tempo
	$HUD/HP.text = "HP: " + str(hp)
	if hp <= 0 and alive:
		kill_self(idSource)


func kill_self(killer_id):
#	var spectator = get_node("/root/TestSceneMP/Map").get_child(0).get_spectator_point()
#	transform = spectator.transform
	visible = false
	alive = false
	$CollisionBody.disabled = true
	
#	rset("slave_alive", alive)
	update_this_other_clients.rpc(multiplayer.get_unique_id(), null, null, alive, null)
	
	$Timers/RespawnTimer.start()
	var self_peer_id = get_tree().get_multiplayer().get_unique_id()
	NetworkManager.send_player_death_packet(killer_id, self_peer_id)


func _on_RespawnTimer_timeout():
	var spawn = get_node("/root/GameSceneMP/Map").get_child(0).get_random_spawn_point()
	transform = spawn.transform
	
#	rset_unreliable("slave_transform", transform)
#	update_this_other_clients.rpc(transform, null, null, null)
	
	hp = 100
	$HUD/HP.text = "HP: " + str(hp)
	alive = true
	
#	rset("slave_alive", alive)

	# TODO joined both rpc calls in 1. seems safe but check if errors arise from this
	update_this_other_clients.rpc(multiplayer.get_unique_id(), transform, null, alive, null)
	
	visible = true
	$CollisionBody.disabled = false
	immune = true
	
	$RotationHelper/Camera3D/Weapons/Primary.get_child(0).reset_weapon(true)
	$RotationHelper/Camera3D/Weapons/Secondary.get_child(0).reset_weapon(true)
	$RotationHelper/Camera3D/Weapons/Melee.get_child(0).reset_weapon(true)
	
	$Timers/SpawnImmunity.start()

#func shoot(current_weapon):
#	current_weapon.shoot()
#	var damage = current_weapon.damage
#	var raycasters = $RotationHelper/Camera/RayCasts
#
#	var targets_dmg = {}
#
#	for idx in range(raycasters.get_child_count()):
#		var ray = raycasters.get_child(idx)
#		ray.force_raycast_update()
#		if not ray.is_colliding():
#			continue
#
#		var target = ray.get_collider()
#		var target_name = target.get_name()
#		var target_root = target.find_parent("Player_*")
#		var target_team = target_root.team
#
#		if target_team != Constants.NO_TEAM and target_team == team:
#			continue
#
#		var target_id = target_root.get_name()
#		target_id = int(target_id.split("_")[1])
#
#		var ray_dmg = damage
#		if target_name == "AreaHead":
#			ray_dmg *= HEAD_MUL
#		elif target_name == "AreaBody":
#			ray_dmg *= BODY_MUL
#
#		if targets_dmg.keys().has(target_id):
#			targets_dmg[target_id] += ray_dmg
#		else:
#			targets_dmg[target_id] = ray_dmg
#
#	if not targets_dmg.empty():
#		$Sound/SFXHitEnemy.play()
#		for idx in range(targets_dmg.keys().size()):
#			var target_id = targets_dmg.keys()[idx]
#			var damage_to_target = targets_dmg[target_id]
#			NetworkManager.damage_player(target_id, damage_to_target)


#func copy_weapon_raycasts(current_weapon):
#	var raycasts_node = $RotationHelper/Camera/RayCasts
#	raycasts_node.queue_free()
#	$RotationHelper/Camera.remove_child(raycasts_node)
#
#	var weapon_raycasts = current_weapon.get_raycasts()
##	var raycasts_instance = weapon_raycasts.instance()
#	var raycasts_instance = weapon_raycasts
#	$RotationHelper/Camera.add_child(raycasts_instance)

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


func _on_NetworkSendRate_timeout():
	update_this_other_clients.rpc(multiplayer.get_unique_id(), transform, vel, null, null)
	
#	rset_unreliable("slave_transform", transform)
#	rset_unreliable("slave_movement", vel)



func _on_spawn_immunity_timeout():
	immune = false
