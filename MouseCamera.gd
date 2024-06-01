extends Camera2D


var dragging = false

		
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom += Vector2(0.5, 0.5)
			return
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom -= Vector2(0.5, 0.5)
			return 
		if event.button_index != MOUSE_BUTTON_RIGHT:
			return

		dragging = event.is_pressed()
		position_smoothing_speed = 0.5 if dragging else 1.0
	elif event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position()
