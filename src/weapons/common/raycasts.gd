extends Node

const HEAD_MUL = 5.0
const BODY_MUL = 1.0
const MEMBER_MUL = 0.75

signal hit_player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func shoot(damage, player_team, player_id):	
	var targets_dmg = {}
	
	for idx in range(get_child_count()):
		var ray = get_child(idx)
		ray.force_raycast_update()
		if not ray.is_colliding():
			continue
		
		var target = ray.get_collider()
		var target_name = target.get_name()
		var target_root = target.find_parent("Player_*")
		var target_team = target_root.team
		
		if target_team != Constants.TEAMS.NO_TEAM and target_team == player_team:
			continue
		
		var target_id = target_root.get_name()
		target_id = int(target_id.split("_")[1])
		
		var ray_dmg = damage
		if target_name == "AreaHead":
			ray_dmg *= HEAD_MUL
		elif target_name == "AreaBody":
			ray_dmg *= BODY_MUL
		
		if targets_dmg.keys().has(target_id):
			targets_dmg[target_id][damage] += ray_dmg
		else:
			targets_dmg[target_id] = {
				"node": target_root,
				"damage": ray_dmg
			}
	
	return targets_dmg
	
#	if not targets_dmg.empty():
#		emit_signal("hit_player")
#		for idx in range(targets_dmg.keys().size()):
##			var target_id = targets_dmg.keys()[idx]
##			var damage_to_target = targets_dmg[target_id]
##			NetworkManager.damage_player(target_id, damage_to_target)
#			var target_id = targets_dmg.keys()[idx]
#			var damage_to_target = targets_dmg[target_id]["damage"]
#			targets_dmg[target_id]["node"].receive_damage(player_id, damage_to_target)
