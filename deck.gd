extends Node2D

var card_scene: PackedScene = preload("res://card.tscn")

@export var default_spot: Node2D

@onready var table := $"../../Table"

var deck: Array[Global.CardDetails] = []

func _ready():
	hide()
	Events.connect('start_game', start)
	Events.connect('populate_hand', populate_hand)

func start():
	reset_deck()
	show()
	default_spot = get_tree().get_current_scene().get_node('Spawn')
	
func _on_input_event(_viewport, event, _shape_idx):
	if (
		!Global.is_active_card_details
			and event is InputEventMouseButton
			and event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
		):
		#print('clicked deck, not handled yet')
		place_card(null)

func reset_deck():
	for suit in Global.SUIT_INDEX:
		for number in Global.NUMBER_INDEX:
			var card = Global.CardDetails.new()
			card.number = number
			card.suit = suit
			deck.append(card)

func place_card(player: Player):
	var is_first_card = default_spot.get_children().size() == 0
	var next_card = deck.pick_random()
	
	if is_first_card:
		var new_card = card_scene.instantiate()
		new_card.number = next_card.number
		new_card.suit = next_card.suit	
		new_card.is_placed = true
		new_card.global_position = default_spot.global_position
		#new_card.player = player
		table.add_child(new_card)
	else:
		player.hand.push_card(next_card)
	
	deck.erase(next_card)

func populate_hand(player: Player):
	for _index in 7:
		var next_card = deck.pick_random()
		player.hand.cards.append(next_card)
		deck.erase(next_card)
