extends Node

var card_scene: PackedScene = preload("res://card.tscn")

var active_player_id: int = 1


func populate_hands():
	pass
	
func get_active_player():
	return get_player(active_player_id)
			
func get_player(player_id):
	for child in get_tree().current_scene.get_node('Players/Spawn').get_children():
		if child.name == str(player_id):
			Global.print('active player %s' % child)
			return child
			
@rpc('any_peer', 'call_local', 'reliable')	
func next_active_player():
	var spawn = get_tree().current_scene.get_node('Players/Spawn')
	var player = get_active_player()
	var index = player.get_index()
	var new_index = index + 1
	
	if new_index == spawn.get_children().size():
		new_index = 0

	var new_player = spawn.get_child(new_index)
	active_player_id = new_player.player_id
			
			

@rpc('any_peer', 'call_local', 'reliable')
func place_card(position, rotation, number, suit, zone, parent_name):
	var card = card_scene.instantiate()
	card.set_meta('author', name)
	card.set_multiplayer_authority(get_multiplayer_authority())
	card.number = number
	card.suit = suit
	card.global_position = position
	card.global_rotation = rotation
	card.scale = Vector2(1, 1)
	card.is_placed = true
	Global.print('adding card %s' % card)
	var table = get_tree().current_scene.get_node('Table')
	table.add_child(card, true)
	table.is_empty = false
	
	next_active_player()
	
	# remove the zone from new card that would be overlapping
	if zone:
		var zone_to_delete = Global.DIRECTION_MAP[zone]
		delete_zone(card, zone_to_delete)

	# remove the zone where we're placing
	if parent_name:
		var parent = get_tree().current_scene.get_node('Table/' + parent_name)
		delete_zone(parent, zone)

func delete_zone(card: Card, zone_to_delete: Global.Directions):
	for zone in card.ZONES:
		if is_instance_valid(zone) and zone.zone_placement == zone_to_delete:
			Global.print('deleting zone %s' % zone_to_delete)
			zone.queue_free()

