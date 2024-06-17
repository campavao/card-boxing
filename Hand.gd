extends Node2D
class_name Hand

@onready var card_node: PackedScene = preload("res://card.tscn")
@onready var player := $"../.."

var cards: Array[Global.CardDetails] = []

@export var CARD_BUFFER_LENGTH = 50

var previous_hand_size = 0

#func _process(_delta):
	#var hand_size = cards.size()
	#if hand_size > 0 and hand_size != previous_hand_size:
		#Global.print('actually in here')
		#show_cards()
		#previous_hand_size = hand_size


func show_cards():
	var start = 0
	for card in cards:
		render_card(card, start)
		start += CARD_BUFFER_LENGTH
		
func render_card(card: Global.CardDetails, start: float = 0):
	var addable_card: Card = card_node.instantiate()
	addable_card.number = card.number
	addable_card.suit = card.suit
	addable_card.position.x = start
	addable_card.player = player
	addable_card.connect("remove_card", _on_remove_card)
	%Path.add_child(addable_card, true)

func push_card(card: Global.CardDetails):
	cards.append(card)
	reshuffle()
	
func reshuffle():
	for child in %Path.get_children():
		%Path.remove_child(child)
	show_cards()

func _on_remove_card(card: Card):
	var found_card = find_card(card)
	if found_card:
		cards.erase(found_card)
		reshuffle()

		
func find_card(to_find: Card):
	for card in cards:
		if card.number == to_find.number and card.suit == to_find.suit:
			return card
