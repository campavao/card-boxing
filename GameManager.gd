extends Node

var card_scene: PackedScene = preload("res://card.tscn")

var active_player_id: int = 1

var score: Dictionary = {}
	
func get_active_player():
	return get_player(active_player_id)
			
func get_player(player_id):
	for child in get_tree().current_scene.get_node('Players/Spawn').get_children():
		if child.name == str(player_id):
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
	Events.emit_signal('pickup_card')

@rpc('any_peer', 'call_local', 'reliable')
func place_card(position, rotation, number, suit, zone, parent_name):
	var card = card_scene.instantiate()
	card.set_meta('author', name)
	card.set_multiplayer_authority(active_player_id)
	card.number = number
	card.suit = suit
	card.global_position = position
	card.global_rotation = rotation
	card.scale = Vector2(1, 1)
	card.is_placed = true
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
		if is_instance_valid(zone) and zone is CardZone and zone.zone_placement == zone_to_delete:
			zone.queue_free()

func init_score():
	for child in get_tree().current_scene.get_node('Players/Spawn').get_children():
		add_player_to_score(child.player_id)

	update_score_label()

func add_player_to_score(player_id):
	score[player_id] = 0

func update_score(player_id):
	score[player_id] += 1
	update_score_label()
	
func update_score_label():
	var label = get_tree().current_scene.get_node('UI/Score')
	label.text = 'Score:'
	for player_id in score:
		var value = score[player_id]
		label.text += '\n' + str(player_id) + ': ' + str(value)
