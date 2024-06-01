extends Node2D
class_name Card

@onready var Face := $Face
@onready var Zone1 := $Zones/CardZone1
@onready var Zone2 := $Zones/CardZone2
@onready var Zone3 := $Zones/CardZone3
@onready var Zone4 := $Zones/CardZone4

var table

@onready var ZONES: Array[CardZone] = [Zone1, Zone2, Zone3, Zone4]

var is_placed = false

# Ace to King
@export var number: Global.Numbers
@export var suit: Global.Suits
@export var player: Player

signal remove_card(card: Card)

var connected: Array[Card]

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
	if multiplayer.is_server():
		move()
		
func move():
	if player and player.is_selected:
		var active_card_details = Global.CardDetails.new()
		active_card_details.number = number
		active_card_details.suit = suit
		Global.active_card_details = active_card_details
		
		if !is_placed:
			follow_mouse()
		
	if is_placed and is_any_disabled():
		enable_all()
		

func follow_mouse():
	global_position = get_global_mouse_position()

	
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
	var first_area = placement_area[0]
	var is_valid_placement = can_place()

	if first_area and is_valid_placement:
		reparent(table)
		global_position = first_area.global_position
		global_rotation = first_area.global_rotation
		scale = Vector2(1, 1)
		connected = [first_area.parent]
		
		var zone_to_delete = Global.DIRECTION_MAP[first_area.zone_placement]
		delete_zone(zone_to_delete)
		first_area.parent.delete_zone(first_area.zone_placement)
		
		is_placed = true
		Global.is_active_card_details = false
		
		first_area.queue_free()
		emit_signal('remove_card', self)
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


func delete_zone(zone_to_delete: Global.Directions):
	for zone in ZONES:
		if is_instance_valid(zone) and zone.zone_placement == zone_to_delete:
			zone.queue_free()
