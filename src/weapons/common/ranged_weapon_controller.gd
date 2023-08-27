extends Node3D

@export var data: RangedWeaponData

var is_firing = false
var slave_shot_fired = false
var previous_slave_shot_fired = false

var is_reloading = false
var is_swaping = false

var curr_ammo_mag = -1
var curr_ammo_reserve = -1

var disabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	curr_ammo_mag = data.max_ammo_mag
	curr_ammo_reserve = data.max_ammo - data.max_ammo_mag


func _process(delta):
	if disabled:
		return
	
	non_master_update(delta)
	if not is_multiplayer_authority():
		return


func can_shoot():
	if is_firing or is_reloading or is_swaping or curr_ammo_mag == 0:
		return false
	else:
		return true


func shoot(team, player_id):
	curr_ammo_mag -= 1
	is_firing = true
	var targets_dmg = $"RayCasts".shoot(data.damage, team, player_id)
	$Particles/Shot.emitting = true
	
#	rset("slave_shot_fired", is_firing)
#	update_this_other_clients.rpc(multiplayer.get_unique_id(), is_firing)
	rpc("update_this_other_clients", multiplayer.get_unique_id(), is_firing)
	
	$SFX/Shot.play()
#	AudioManager.play("res://assets/weapons/primary/ak_47/sfx/AKM Single Shot2.wav")
	var secs_per_shot = 1.0/(data.fire_rate_rpm/60.0)
	$Timers/FireRateTimer.start(secs_per_shot)
	
	return targets_dmg

func holdster():
	is_reloading = false
	disabled = true


func can_reload():
	if curr_ammo_reserve == 0 or is_reloading or is_swaping:
		return false
	return true


func reload():
	$Timers/ReloadTimer.start(data.reload_time_sec)
	is_reloading = true


func _on_FireRateTimer_timeout():
	is_firing = false
#	update_this_other_clients.rpc(multiplayer.get_unique_id(), is_firing)
	rpc("update_this_other_clients", multiplayer.get_unique_id(), is_firing)
#	rset("slave_shot_fired", is_firing)

func non_master_update(delta):
	if is_multiplayer_authority():
		return
	
	if slave_shot_fired and not previous_slave_shot_fired:
		$SFX/Shot3D.play()
		previous_slave_shot_fired = true
	
	if not slave_shot_fired and previous_slave_shot_fired:
		previous_slave_shot_fired = false

# TODO need anotations?
@rpc
func update_this_other_clients(id, new_is_firing):
	if get_multiplayer_authority() != id:
		return
	slave_shot_fired = new_is_firing


func set_raycasts_position(new_position):
	$RayCasts.global_transform = new_position


func _on_visibility_changed():
	if visible:
		is_swaping = true
		$Timers/SwapTimer.start(data.swap_time_sec)
		reset_weapon(false)


func _on_SwapTimer_timeout():
	is_swaping = false


func _on_ReloadTimer_timeout():	
	if not is_reloading:
		return
	
	var ammo_to_fill = data.max_ammo_mag - curr_ammo_mag
	if curr_ammo_reserve >= ammo_to_fill:
		curr_ammo_mag += ammo_to_fill
		curr_ammo_reserve -= ammo_to_fill
	else:
		curr_ammo_mag += curr_ammo_reserve
		curr_ammo_reserve = 0
	
	is_reloading = false

func reset_weapon(reset_ammo: bool):
	disabled = false
	is_firing = false
	is_reloading = false
	if reset_ammo:
		curr_ammo_mag = data.max_ammo_mag
		curr_ammo_reserve = data.max_ammo - data.max_ammo_mag
