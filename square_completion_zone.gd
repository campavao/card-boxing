extends Area2D
class_name SquareCompletionZone

@export var is_complete = false
@export var is_disabled := true

var connected = []

var completor = null

func _process(delta):
	$CollisionShape2D.disabled = is_disabled
		

func _on_area_entered(area):
	if is_disabled:
		return
		
	var parent = get_parent().get_parent()
	if area is SquareCompletionZone and !area.is_disabled:
		var area_parent = area.get_parent().get_parent()
		if parent.get_index() < area_parent.get_index():
			return # only process for newest card
			
		connected.append(area)
		
		if area.connected.size() > 0:
			connected.append_array(area.connected)
		
		area.queue_free()
		
		if connected.size() == 3:
			is_complete = true
			completor = parent.get_multiplayer_authority()
			GameManager.update_score(completor)
			
