extends Node


var player_count = 0

func _on_button_pressed():
	hide_start.rpc()

@rpc("any_peer", "call_local", "reliable")
func hide_start():
	Events.emit_signal('start_game')
	$"UI/Button".hide()
	
	for child in %Spawn.get_children():
		Events.emit_signal('populate_hand', child)

func _on_spawn_child_entered_tree(node):
	if node is Player:
		player_count += 1
		$"UI/Player Count".text = 'Player Count: ' + str(player_count)


func _on_spawn_child_exiting_tree(node):
	if node is Player:
		player_count -= 1
		$"UI/Player Count".text = 'Player Count: ' + str(player_count)
