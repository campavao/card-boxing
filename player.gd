extends Node2D
class_name Player

@export var input_sync: MultiplayerSynchronizer
@onready var hand := $UI/Hand
@onready var id_label = $UI/ID
@onready var ui = $UI
@export var is_selected := false

@export var player_id := 1:
	set(id):
		player_id = id
		%InputSync.set_multiplayer_authority(id)

func _ready():
	print('Player connected in player instance %d' % player_id)
	if multiplayer.get_unique_id() == player_id:
		$Camera2D.make_current()
		ui.show()
	else:
		$Camera2D.enabled = false
		ui.hide()

	is_selected = player_id == 1
	id_label.text = str(player_id)
	input_sync = %InputSync
