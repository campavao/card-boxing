extends Area2D
class_name SquareZone

const Numbers = Global.Numbers
const Suits = Global.Suits
const Zones = [1, 2, 3, 4]
const SquareGrid = {
	1: [2, 4],
	2: [1, 3],
	3: [2, 4],
	4: [1, 3]
}

@export var is_filled: bool = false
@export var zone = 0


var required_numbers: Array[Numbers] = []
var required_suits: Array[Suits] = []

func is_valid(card: Card):
	return (
		is_filled
		or required_numbers.all(func(number): return number == card.number)
		or required_suits.all(func(suit): return suit == card.suit)
	)
	
func add_number(card: Card):
	required_numbers.append(card.number)
	
func add_suit(card: Card):
	required_suits.append(card.suit)
	
func add_requirement(card: Card):
	add_number(card)
	add_suit(card)

