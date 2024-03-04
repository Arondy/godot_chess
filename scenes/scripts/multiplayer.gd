extends Node2D

signal player_connected(peerId, playerInfo)
signal player_disconnected(peerId)
signal server_disconnected

var lobbyScene: PackedScene = preload("res://scenes/lobby.tscn")
var peer = ENetMultiplayerPeer.new()
@export var address: String = "localhost"
@export var port: int = 135

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server_ok)
	multiplayer.connection_failed.connect(_on_connected_fail_server_ok)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
func _on_host_button_pressed():
	var error = peer.create_server(port, 2)
	
	if error:
		return error
		
	multiplayer.multiplayer_peer = peer
	addPlayerData({"name": $Nickname.text}, multiplayer.get_unique_id())
	get_tree().change_scene_to_packed(lobbyScene)
	print("Host is waiting for players")

func _on_join_button_pressed():
	peer.create_client(address, port)
	multiplayer.multiplayer_peer = peer
	
func _on_player_connected(id):
	var unId = multiplayer.get_unique_id()
	print("from %d: Player %d connected" % [unId, id])

func _on_player_disconnected(id):
	print("Player %d disconnected" % id)
	GameManager.players.erase(id)
	#var players = get_tree().get_nodes_in_group("Player")
	#for i in players:
		#if i.name == str(id):
			#i.queue_free()
	player_disconnected.emit(id)

func _on_connected_to_server_ok():
	var unId = multiplayer.get_unique_id()
	print("from %d: Connection to server established!" % unId)
	addPlayerData.rpc_id(1, {"name": $Nickname.text}, unId)
	player_connected.emit(unId, GameManager.players[unId])

func _on_connected_fail_server_ok():
	print("Connection to server failed!")
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	print("Lost connection to the server!")
	multiplayer.multiplayer_peer = null
	GameManager.players.clear()
	server_disconnected.emit()

@rpc("any_peer", "reliable")
func addPlayerData(data, id):
	if !GameManager.players.has(id):
		GameManager.players[id] = data
	if multiplayer.is_server():
		for player in GameManager.players:
			addPlayerData.rpc(GameManager.players[player], player)
