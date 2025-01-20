extends Node

const SERVER_PORT = 3928

var multiplayer_player = preload("res://Prefab/player.tscn")

var _players_spawn_node
var host_mode_enabled = false

func become_host():
	print("Making Lobby...")
	
	_players_spawn_node = get_tree().get_current_scene().get_node("Players")
	
	host_mode_enabled = true
	
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)
	
	multiplayer.multiplayer_peer = server_peer
	
	_add_player_to_game(1)
	
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(_remove_player_from_game)
	
	upnp_setup()

func join_as_player(Server_IP):
	print("Joining Lobby as Player...")
	
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(Server_IP, SERVER_PORT)
	
	multiplayer.multiplayer_peer = client_peer

func join_as_spectator(Server_IP):
	
	print("Joining Lobby as Spectator...")
	
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(Server_IP, SERVER_PORT)
	
	multiplayer.multiplayer_peer = client_peer

func _add_player_to_game(id: int):
	print("Player %s joined the game!" % id)
	
	var player_to_add = multiplayer_player.instantiate()
	player_to_add.player_id = id
	player_to_add.name = str(id)
	_players_spawn_node.add_child(player_to_add, true)

func _remove_player_from_game(id: int):
	print("Player %s left the game!" % id)
	if not _players_spawn_node.has_node(str(id)):
		return
	_players_spawn_node.get_node(str(id)).queue_free()


func upnp_setup():
	var upnp = UPNP.new()
	var discover_result = upnp.discover()
	
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, 
	"UPNP Discover Failed! Error %s" % discover_result)
	
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), 
	"UPNP Invalid Gateway!")
	
	var map_result = upnp.add_port_mapping(SERVER_PORT)
	
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, 
	"UPNP Port Mapping Failed! Error %s" % map_result)
	
	print("Succes! Join Address: %s" % upnp.query_external_address())
