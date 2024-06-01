extends Node

var player := preload('res://player.tscn')

var spawn: Node2D;

# Constants
const PORT = 8080
const SERVER_IP = "127.0.0.1"

# Variables
var is_server = false

# Handle new peer connection
func _on_peer_connected(id: int):
	print("New peer connected: %d" % id)
	
	var player_to_add = player.instantiate()
	player_to_add.player_id = id
	player_to_add.name = str(id)
	
	spawn.add_child(player_to_add, true)


# Handle disconnection
func _on_peer_disconnected(id: int):
	print("Peer disconnected: %d" % id)
	if not spawn.has_node(str(id)):
		return
	spawn.get_node(str(id)).queue_free()
	
func remove_single_player():
	var player_to_remove = get_tree().get_current_scene().get_node('Player')
	player_to_remove.queue_free()
	
func become_host():
	print('starting host')
	Events.emit_signal('start_game')
	
	spawn = get_tree().get_current_scene().get_node('Spawn')
	
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(PORT)
	
	multiplayer.multiplayer_peer = server_peer
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	
	print('becoming host again?')
	_on_peer_connected(1)


	
func join_game():
	print('joining')
	
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP, PORT)
	
	multiplayer.multiplayer_peer = client_peer
	
	
