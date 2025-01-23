extends Node

const SERVER_PORT = 3928

var multiplayer_player = preload("res://Prefab/player.tscn")

var _players_spawn_node
var host_mode_enabled = false

var peer = ENetMultiplayerPeer.new()

func _ready():
	multiplayer.server_disconnected.connect(_disconnect_from_server)

func become_host():
	print("Making Lobby...")

func join_as_player(Server_IP):
	print("Joining Lobby as Player...")

func join_as_spectator(Server_IP):
	print("Joining Lobby as Spectator...")

func _add_player_to_game(id: int):
	print("Player %s joined the game!" % id)

func _remove_player_from_game(id: int):
	print("Player %s left the game!" % id)

func _disconnect_from_server():
	get_tree().get_current_scene().unhide_UI()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	peer.close()
