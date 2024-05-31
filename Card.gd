extends Node2D
class_name Card

@onready var Face := $Face
@onready var Zone1 := %CardZone1
@onready var Zone2 := %CardZone2
@onready var Zone3 := %CardZone3
@onready var Zone4 := %CardZone4

@onready var ZONES: Array[CardZone] = [Zone1, Zone2, Zone3, Zone4]

var is_placed = false

# Ace to King
@export var number: Global.Numbers
@export var suit: Global.Suits

const BASE_NUMBER_OFFSET = 12
const BASE_SUIT_OFFSET = 3
const WIDTH = 40
const HEIGHT = 58

const LAST_CARD_INDEX = 13

const OFFSET_MODIFIER = 65

func _ready():
	update_face()
		
func update_face():
	if (number == Global.Numbers.Joker):
		print('joker time')
		var x = BASE_NUMBER_OFFSET + (OFFSET_MODIFIER * LAST_CARD_INDEX)
		var y = BASE_SUIT_OFFSET + (OFFSET_MODIFIER * 3)
		
		Face.region_rect = Rect2(x, y, WIDTH, HEIGHT)
	else:
		var cardIndex = Global.NUMBER_INDEX.find(number)
		if cardIndex == -1:
			print('invalid number', number)
			return
			
		var suitIndex = Global.SUIT_INDEX.find(suit)
		if suitIndex == -1:
			print('invalid suit', suit)
			return
				
		var x = BASE_NUMBER_OFFSET + (OFFSET_MODIFIER * cardIndex)
		var y = BASE_SUIT_OFFSET + (OFFSET_MODIFIER * suitIndex)
		
		Face.region_rect = Rect2(x, y, WIDTH, HEIGHT)

var selected = false

func _process(_delta):
	if selected:
		var active_card = Global.ActiveCard.new()
		active_card.number = number
		active_card.suit = suit
		Global.active_card = active_card
		
		if !is_placed:
			follow_mouse()
		
	adjust_zones(selected)


func follow_mouse():
	global_position = get_global_mouse_position()

var placement_area: Array[Area2D] = []

func _on_base_zone_input_event(_viewport, event, _shape_idx):
	if is_placed:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		selected = event.pressed
		
		if !event.pressed and placement_area.size() > 0:
			place()


func adjust_zones(disable: bool):
	for zone in ZONES:
		if is_instance_valid(zone):
			zone.is_disabled = disable
	

func place():
	var first_area = placement_area[0]
	var is_valid_placement = can_place()

	if first_area and is_valid_placement:
		global_position = first_area.global_position
		global_rotation = first_area.global_rotation
		var zone_to_delete = Global.DIRECTION_MAP[first_area.zone_placement]
		delete_zone(zone_to_delete)
		first_area.queue_free()
		is_placed = true
		Global.is_active_card = false
	
func is_valid(area: CardZone):
	return !area.is_base and area.is_match 

func can_place():
	return placement_area.all(is_valid)
	
func print_card_details(area: CardZone):
	return {
		"number": area.parent.number,
		"suit": area.parent.suit
	}

func _on_base_zone_area_entered(area):
	if area is CardZone and !area.is_base:
		placement_area.append(area)
		
func _on_base_zone_area_exited(area):
	if area is CardZone:
		var index = placement_area.find(area)
		if index != -1:
			placement_area.remove_at(index)
			

func delete_zone(zone_to_delete: Global.Directions):
	for zone in ZONES:
		if zone.zone_placement == zone_to_delete:
			zone.queue_free()
