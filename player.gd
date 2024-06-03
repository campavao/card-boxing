extends Node2D
class_name Player


@onready var hand := $UI/Hand
@onready var id_label = $UI/ID
@onready var ui = $UI

var is_selected := false

@export var player_id := 1

@export var mouse_position: Vector2 = Vector2(0, 0)

func _ready():
	print('Player connected in player instance %d' % player_id)
	if multiplayer.get_unique_id() == player_id:
		print('Make current for %d' % player_id)
		$Camera2D.make_current()
		ui.show()
	else:
		$Camera2D.enabled = false
		ui.hide()

	id_label.text = str(player_id)

func _physics_process(delta):
	mouse_position = %InputSync.mouse_position

func _enter_tree():
	%InputSync.set_multiplayer_authority(str(name).to_int())
