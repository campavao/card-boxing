extends MultiplayerSynchronizer

@onready var player = $".."

var mouse_position: Vector2 = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_position = event.global_position
