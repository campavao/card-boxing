extends Node

enum Suits {
	hearts,
	diamonds,
	clubs,
	spades,
}

enum Numbers {
	Ace,
	Two,
	Three,
	Four,
	Five,
	Six,
	Seven,
	Eight,
	Nine,
	Ten,
	Jack,
	Queen,
	King,
	Joker
}

const NUMBER_INDEX = [
	Numbers.Ace,
	Numbers.Two,
	Numbers.Three,
	Numbers.Four,
	Numbers.Five,
	Numbers.Six,
	Numbers.Seven,
	Numbers.Eight,
	Numbers.Nine,
	Numbers.Ten,
	Numbers.Jack,
	Numbers.Queen,
	Numbers.King,
	#Numbers.Joker
]
const SUIT_INDEX = [
	Suits.hearts,
	Suits.diamonds,
	Suits.clubs,
	Suits.spades,
]

enum Directions {
	North,
	South,
	East,
	West
}

# Depending on which CardZone a Card is placed into, 
# this determines which CardZones to combine
const DIRECTION_MAP = {
	Directions.North: Directions.East,
	Directions.East: Directions.South,
	Directions.South: Directions.West,
	Directions.West: Directions.North,
}

var is_active_card_details = false

class CardDetails:
	var number: Numbers
	var suit: Suits

var active_card_details: CardDetails = null

var active_card: Card = null

const CARD_ZONE_COLLISION_LAYER = 9
