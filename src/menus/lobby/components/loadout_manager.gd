extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#	setup_primary_weapon()
#	setup_secondary_weapon()
#	setup_melee_weapon()


#func setup_primary_weapon():
#	for id in Constants.PRIMARY_WEAPONS:
#		var name = Constants.PRIMARY_WEAPONS[id]
#		$Primary/PrimaryOption.add_item(name, id)
#
#	var idx = $Primary/PrimaryOption.get_item_index(NetworkManager.get_my_info().primary_weapon)
#	$Primary/PrimaryOption.select(idx)
#
#
#func setup_secondary_weapon():
#	for id in Constants.SECONDARY_WEAPONS:
#		var name = Constants.SECONDARY_WEAPONS[id]
#		$Secondary/SecondaryOption.add_item(name, id)
#
#	var idx = $Secondary/SecondaryOption.get_item_index(NetworkManager.get_my_info().secondary_weapon)
#	$Secondary/SecondaryOption.select(idx)
#
#
#func setup_melee_weapon():
#	for id in Constants.MELEE_WEAPONS:
#		var name = Constants.MELEE_WEAPONS[id]
#		$Melee/MeleeOption.add_item(name, id)
#
#	var idx = $Melee/MeleeOption.get_item_index(NetworkManager.get_my_info().melee_weapon)
#	$Melee/MeleeOption.select(idx)
#
#
#func _on_PrimaryOption_item_selected(index):
#	var primary_id = $Primary/PrimaryOption.get_selected_id()
#	NetworkManager.update_player_weapons_local(primary_id, null, null)
#
#
#func _on_SecondaryOption_item_selected(index):
#	var secondary_id = $Secondary/SecondaryOption.get_selected_id()
#	NetworkManager.update_player_weapons_local(null, secondary_id, null)
#
#
#func _on_MeleeOption_item_selected(index):
#	var melee_id = $Melee/MeleeOption.get_selected_id()
#	NetworkManager.update_player_weapons_local(null, null, melee_id)
