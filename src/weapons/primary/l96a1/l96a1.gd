#extends Node3D
#
#var firerate_rpm = 40
#const damage = 120
#
#var firing = false
#slave var slave_shot_fired = false
#var previous_slave_shot_fired = false
#
#var raycasts = preload("res://weapons/primary/l96a1/sniper_raycasts.tscn")
#
## Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.
#
#func _process(delta):
#	if not visible:
#		return
#
#	non_master_update(delta)
#	if not is_multiplayer_authority():
#		return
#
#
#func shoot():
#	firing = true
#	$Particles/Shot.emitting = true
#	rset("slave_shot_fired", firing)
#	$SFX.play()
#	var secs_per_shot = 1.0/(firerate_rpm/60.0)
#	$FireRateTimer.start(secs_per_shot)
#
#
#func _on_FireRateTimer_timeout():
#	firing = false
#	rset("slave_shot_fired", firing)
#
#func non_master_update(delta):
#	if is_multiplayer_authority():
#		return
#
#	if slave_shot_fired and not previous_slave_shot_fired:
#		$SFX3D.play()
#		previous_slave_shot_fired = true
#
#	if not slave_shot_fired and previous_slave_shot_fired:
#		previous_slave_shot_fired = false
#
#
#func get_raycasts():
#	return raycasts
#
