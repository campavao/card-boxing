extends Camera2D

@export var speed = 30

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	translate(speed * velocity)
		
