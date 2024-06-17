extends Node2D

var card_scene: PackedScene = preload("res://card.tscn")

@onready var table := $"../../Table"

var deck: Array[Global.CardDetails] = []

func _ready():
	hide()
	Events.connect('start_game', start)
	Events.connect('populate_hand', _on_populate_hand)
	Events.connect('pickup_card', _on_pickup_card)
	
func _process(_delta):
	$Label.text = str(deck.size())
	
func start():
	reset_deck()
	show()
	
func _on_input_event(_viewport, event, _shape_idx):
	if (
		!Global.is_active_card_details
			and event is InputEventMouseButton
			and event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
		):
		click_deck()

func reset_deck():
	deck = []
	for suit in Global.SUIT_INDEX:
		for number in Global.NUMBER_INDEX:
			var card = Global.CardDetails.new()
			card.number = number
			card.suit = suit
			deck.append(card)


func click_deck():
	var player = GameManager.get_active_player()
	if player.player_id != multiplayer.get_unique_id():
		return
		
	var is_first_card = table.is_empty
	var next_card = deck.pick_random()
	
	if is_first_card:
		GameManager.place_card.rpc(table.first_spot.global_position * 2, 0, next_card.number, next_card.suit, null, null)
	else:
		player.hand.push_card(next_card)
	
	GameManager.next_active_player.rpc()
	var card_index = deck.find(next_card)
	remove_card.rpc(card_index)

func _on_pickup_card():
	if multiplayer.get_unique_id() == GameManager.active_player_id:
		Global.print('one pickup card')
		var next_card = deck.pick_random()
		push_card.rpc(deck.find(next_card))

@rpc("any_peer", "call_local", "reliable")
func push_card(card_index):
	var player = GameManager.get_active_player()
	var next_card = deck[card_index]
	player.hand.push_card(next_card)
	remove_card(card_index)
	
func _on_populate_hand():
	if multiplayer.get_unique_id() == get_multiplayer_authority():
		populate_hands()
		Global.print('one populate hands')

func populate_hands():
	var players = get_tree().current_scene.get_node('Players/Spawn').get_children()
	for player in players:
		for _index in 7:
			var card = deck.pick_random()
			var card_index = deck.find(card)
			add_card_to_hand.rpc(player.player_id, card_index)


@rpc("any_peer", "call_local", "reliable")
func add_card_to_hand(player_id, card_index):
	var card = deck[card_index]
	var this_player = GameManager.get_player(player_id)
	this_player.hand.push_card(card)
	deck.erase(card)
	
@rpc("any_peer", 'call_local', 'reliable')
func remove_card(card_index):
	var card = deck[card_index]
	deck.erase(card)
