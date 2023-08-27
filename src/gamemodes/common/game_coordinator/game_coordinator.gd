extends Node


var playerNodes = {}
var myPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func update_player_node_refs():
	var playerNodesList = $Players.get_children()
	
	for pNode in playerNodesList:
		var node_name = pNode.get_name()
		var player_id = int(node_name.split("_")[1])
		playerNodes[player_id] = pNode
		
	
	myPlayer = playerNodes[multiplayer.get_unique_id()]


func damage_player(damage, idSource, idTarget):
	rpc_id(idTarget, "receive_damage", damage, idSource)


@rpc("any_peer")
func receive_damage(damage, idSource):
	myPlayer.receive_damage(damage, idSource)
