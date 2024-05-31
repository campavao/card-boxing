extends Node2D

var card_scene: PackedScene = preload("res://card.tscn")

@export var default_spot: Marker2D

@onready var hand := $"../Hand"

var deck: Array[Global.ActiveCard] = []

func _ready():
	reset_deck()
	place_card(true)
	populate_hand()
	
	

func _on_input_event(_viewport, event, _shape_idx):
	if !Global.is_active_card and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		place_card(false)

func reset_deck():
	for suit in Global.SUIT_INDEX:
		for number in Global.NUMBER_INDEX:
			var card = Global.ActiveCard.new()
			card.number = number
			card.suit = suit
			deck.append(card)

func place_card(is_first_card: bool):
	var next_card = deck.pick_random()
	var new_card = card_scene.instantiate()
	new_card.number = next_card.number
	new_card.suit = next_card.suit
	if is_first_card:
		default_spot.add_child(new_card)
	else:
		new_card.selected = true
		#Global.is_active_card = true
		get_parent().get_parent().add_child(new_card)
	
	var remove_card_index = deck.find(next_card)
	deck.remove_at(remove_card_index)

func populate_hand():
	for _index in 7:
		var next_card = deck.pick_random()
		hand.cards.append(next_card)
