extends Node3D

var firerate_rpm = 40
const damage = 120

var firing = false
slave var slave_shot_fired = false
var previous_slave_shot_fired = false

var raycasts = preload("res://weapons/scenes/sniper/sniper_raycasts.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	if not selected:
		return
	
	non_master_update(delta)
	if not is_multiplayer_authority():
		return


func setup(weapon_stats_path):
	var test_json_conv = JSON.new()
	test_json_conv.parse()
	var stats = test_json_conv.get_data()


func shoot():
	firing = true
	$Particles/Shot.emitting = true
	rset("slave_shot_fired", firing)
	$SFX.play()
	var secs_per_shot = 1.0/(firerate_rpm/60.0)
	$FireRateTimer.start(secs_per_shot)


func _on_FireRateTimer_timeout():
	firing = false
	rset("slave_shot_fired", firing)

func non_master_update(delta):
	if is_multiplayer_authority():
		return
	
	if slave_shot_fired and not previous_slave_shot_fired:
		$SFX3D.play()
		previous_slave_shot_fired = true
	
	if not slave_shot_fired and previous_slave_shot_fired:
		previous_slave_shot_fired = false


func get_raycasts():
	return raycasts

