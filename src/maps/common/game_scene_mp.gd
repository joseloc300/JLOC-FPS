extends Node3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if multiplayer.is_server():
		NetworkManager.pre_configure_game()
	else:
		NetworkManager.done_loading()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
