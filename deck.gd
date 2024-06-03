extends Node2D

var card_scene: PackedScene = preload("res://card.tscn")

@export var default_spot: Marker2D

@onready var table := $"../../Table"

var deck: Array[Global.CardDetails] = []

func _ready():
	hide()
	Events.connect('start_game', start)
	Events.connect('populate_hand', _on_populate_hand)


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
	for suit in Global.SUIT_INDEX:
		for number in Global.NUMBER_INDEX:
			var card = Global.CardDetails.new()
			card.number = number
			card.suit = suit
			deck.append(card)


func click_deck():
	var is_first_card = default_spot.get_children().size() == 0
	var next_card = deck.pick_random()
	var player = get_active_player()
	
	if is_first_card:
		place_card.rpc(next_card.number, next_card.suit)
	else:
		player.hand.push_card(next_card)
	
	deck.erase(next_card)

@rpc("any_peer", "call_local", "reliable")
func place_card(number, suit):
	var new_card = card_scene.instantiate()
	new_card.number = number
	new_card.suit = suit	
	new_card.is_placed = true
	new_card.global_position = default_spot.global_position
	default_spot.add_child(new_card)
	
func get_active_player():
	for child in %Spawn.get_children():
		if child.name == str(%GameManager.active_player_id):
			return child

func _on_populate_hand(player: Player):
	for _index in 7:
		var next_card = deck.pick_random()
		player.hand.cards.append(next_card)
		deck.erase(next_card)
