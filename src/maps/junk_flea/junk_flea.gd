extends Node3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func get_random_spawn_point():
	var n_spawns = $SpawnPoints/All.get_child_count()
	var random_idx = randi() % n_spawns
	var random_spawn = $SpawnPoints/All.get_child(random_idx)
	
	return random_spawn

func get_spectator_point():
	var spectator_point = $Spectator/Spectator0.transform
	
	return spectator_point
