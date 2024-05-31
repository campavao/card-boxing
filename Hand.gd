extends Node2D
class_name Hand

@onready var card_node: PackedScene = preload("res://card.tscn")

var cards: Array[Global.ActiveCard] = []

@export var CARD_BUFFER_LENGTH = 50

func _process(_delta):
	if cards.size() > 0 and %Path.get_child_count() != cards.size():
		show_cards()

func show_cards():
	var start = 0
	for card in cards:
		var addable_card = card_node.instantiate()
		addable_card.number = card.number
		addable_card.suit = card.suit
		addable_card.position.x = start
		addable_card.adjust_zones(true)
		%Path.add_child(addable_card)
		start += CARD_BUFFER_LENGTH
