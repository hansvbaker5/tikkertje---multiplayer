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
	
	_players_spawn_node = get_tree().get_current_scene().get_node("Players")
	
	host_mode_enabled = true
	peer.create_server(SERVER_PORT)
	
	multiplayer.multiplayer_peer = peer
	
	_add_player_to_game(1)
	
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(_remove_player_from_game)
	
	#upnp_setup()

func join_as_player(Server_IP):

	print("Joining Lobby as Player...")
	peer.create_client(Server_IP, SERVER_PORT)
	
	multiplayer.multiplayer_peer = peer

func join_as_spectator(Server_IP):
	
	print("Joining Lobby as Spectator...")
	peer.create_client(Server_IP, SERVER_PORT)
	
	multiplayer.multiplayer_peer = peer
	
	multiplayer.server_disconnected.connect(_disconnect_from_server)

func _add_player_to_game(id: int):
	print("Player %s joined the game!" % id)
	
	var player_to_add = multiplayer_player.instantiate()
	player_to_add.player_id = id
	player_to_add.name = str(id)
	player_to_add.player_name = "Player: " + str(id)
	player_to_add.set_playername()
	_players_spawn_node.add_child(player_to_add, true)

func _remove_player_from_game(id: int):
	print("Player %s left the game!" % id)
	if not _players_spawn_node.has_node(str(id)):
		return
	_players_spawn_node.get_node(str(id)).queue_free()
	get_tree().get_current_scene().set_who_it_is.rpc()

func _disconnect_from_server():
	get_tree().get_current_scene().unhide_UI()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	peer.close()

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
