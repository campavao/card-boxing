extends Node2D
class_name Card

var card_scene = preload("res://card.tscn")

@onready var Face := $Face

var table

var ZONES: Array[Node] = []

@export var is_placed = false

# Ace to King
@export var number: Global.Numbers
@export var suit: Global.Suits
@export var player: Player

signal remove_card(card: Card)

var previous_location: Vector2

const BASE_NUMBER_OFFSET = 12
const BASE_SUIT_OFFSET = 3
const WIDTH = 40
const HEIGHT = 58
const LAST_CARD_INDEX = 13
const OFFSET_MODIFIER = 65

func _ready():
	update_face()
	table = get_tree().current_scene.find_child('Table')
	Events.connect("add_placement_area", add_placement)
	Events.connect("remove_placement_area", remove_placement)
	name = Global.get_number_name(number) + "_" + Global.get_suit_name(suit)
	ZONES = get_node('Zones').get_children() 
	
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

func _physics_process(delta):
	if selected:
		move()
	
	if is_placed and is_any_disabled():
		enable_all()
		
func move():
	var active_card_details = Global.CardDetails.new()
	active_card_details.number = number
	active_card_details.suit = suit
	Global.active_card_details = active_card_details
	
	if !is_placed:
		follow_mouse()

func follow_mouse():
	global_position = player.mouse_position

	
func update_position(new_position):
	global_position = new_position

var placement_area: Array[Area2D] = []

func _on_base_zone_input_event(_viewport, event, _shape_idx):
	if is_placed:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		selected = event.pressed
		
		if selected:
			Global.active_card = self
			previous_location = global_position
		else:
			Global.active_card = null
			global_position = previous_location
		
		if !event.pressed and placement_area.size() > 0:
			place()


func enable_all():
	for zone in ZONES:
		if is_instance_valid(zone):
			zone.is_disabled = false
	
func is_any_disabled():
	return ZONES.any(is_disabled)

func is_disabled(zone):
	return is_instance_valid(zone) and zone.is_disabled

func place():
	if GameManager.get_active_player().player_id != multiplayer.get_unique_id():
		return
		
	var first_area = placement_area[0]
	var is_valid_placement = can_place()

	if first_area and is_valid_placement:
		GameManager.place_card.rpc(
			first_area.global_position,
			first_area.global_rotation, 
			number, 
			suit,
			first_area.zone_placement,
			first_area.parent.name
		)
		
		GameManager.delete_zone(self, first_area.zone_placement)

		first_area.queue_free()
		emit_signal('remove_card', self)
		queue_free()
		
	else:
		global_position = previous_location

	
func is_valid(area: CardZone):
	return !area.is_base and area.is_match 

func can_place():
	return placement_area.all(is_valid)
	
func print_card_details(area: CardZone):
	return {
		"number": area.parent.number,
		"suit": area.parent.suit
	}

func add_placement(area: Area2D):
	if area is CardZone and !area.is_base and !area.is_disabled:
		placement_area.append(area)

func remove_placement(area: Area2D):
	placement_area.erase(area)

