extends Area2D
class_name CardZone

const Directions = Global.Directions


@export var is_base := false
@export var is_disabled := false
@export var zone_placement: Directions = Directions.North

var parent: Card
var other_parents: Array[Card] = []

var hide_border = is_base or is_disabled

var is_match = false
var prev_active_card_details = null

func _ready():
	$Border.hide()
	var possible_parent = get_parent().get_parent()
	if possible_parent is Card:
		parent = possible_parent
	name = parent.name + "_" + name

func _process(_delta):
	hide_border = is_base or is_disabled
	visible = !is_disabled
	
	if parent.is_placed:
		$OverlapZone/CollisionShape2D.disabled = false
	
	if hide_border:
		$Border.hide()
		
	if prev_active_card_details == null and Global.active_card_details != null:
		is_valid()
		
	var is_prev_available = prev_active_card_details != null
	var is_global_available = Global.active_card_details != null
	var is_prev_and_current_available = is_prev_available and is_global_available
	
	if is_prev_and_current_available:
		var is_number_match = prev_active_card_details.number != Global.active_card_details.number
		var is_suit_match = prev_active_card_details.suit != Global.active_card_details.suit
		
		if is_number_match or is_suit_match:
			is_valid()
	
	$DebugBorder/Label.text = str(1 + other_parents.size())

	
func highlight():
	var card = Global.active_card

	if card and !card.is_placed:
		if hide_border:
			return
		
		if is_match:
			Events.emit_signal("add_placement_area", self)
			$Border.show()

func is_card(area):
	return area is CardZone and area.is_base
	
func is_valid():
	prev_active_card_details = Global.active_card_details
	var this_matches = Global.active_card_details != null and is_parent_valid(parent)
	if this_matches and other_parents.size() > 0:
		var others_match = other_parents.all(is_parent_valid)
		is_match = this_matches and others_match
	else:
		is_match = this_matches

func is_parent_valid(parent_to_check):
	return Global.active_card_details.number == parent_to_check.number or Global.active_card_details.suit == parent_to_check.suit

func _on_overlap_zone_area_entered(area):
	if area is CardZone:
		if area.is_base:
			Global.print('base found')
			queue_free()
		elif area != self and area.parent.is_placed:
			area.other_parents.append(parent)
			if other_parents.size() > 0 and area.other_parents.size() > 0:
				area.other_parents.append_array(other_parents)
			Global.print('base entered. I am %s' % zone_placement)
			#queue_free()

func _on_mouse_entered():
	highlight()

func _on_mouse_exited():
	Events.emit_signal("remove_placement_area", self)
	$Border.hide()


func _on_area_entered(area):
	if is_base and parent.is_placed and area.parent.is_placed:
		area.queue_free()
