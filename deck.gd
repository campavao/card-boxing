extends Node2D

var card_scene: PackedScene = preload("res://card.tscn")

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
	var player = GameManager.get_active_player()
	if player.player_id != multiplayer.get_unique_id():
		return
	var is_first_card = table.is_empty
	var next_card = deck.pick_random()
	
	if is_first_card:
		GameManager.place_card.rpc(table.first_spot.global_position, 0, next_card.number, next_card.suit, null, null)
	else:
		player.hand.push_card(next_card)
	
	GameManager.next_active_player.rpc()
	deck.erase(next_card)


func _on_populate_hand(player: Player):
	for _index in 7:
		var next_card = deck.pick_random()
		player.hand.cards.append(next_card)
		deck.erase(next_card)
