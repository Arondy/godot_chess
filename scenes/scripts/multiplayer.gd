extends Node2D

signal player_connected(peerId, playerInfo)
signal player_disconnected(peerId)
signal server_disconnected

var lobbyScene: PackedScene = preload("res://scenes/lobby.tscn")
var peer = ENetMultiplayerPeer.new()
@export var adress: String = "127.0.0.1"
@export var port: int = 8080

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server_ok)
	multiplayer.connection_failed.connect(_on_connected_to_server_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
func _on_host_button_pressed():
	var error = peer.create_server(port, 2)
	
	if error:
		return error
		
	multiplayer.multiplayer_peer = peer
	add_player_data(multiplayer.get_unique_id(), {"name": $Nickname.text})
	var scene = lobbyScene.instantiate()
	$"/root".add_child(scene)
	hide()
	adress = IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")), IP.TYPE_IPV4)
	print("IP adress is: " + adress + "\nHost is waiting for players...")

func _on_join_button_pressed():
	peer.create_client(adress, port)
	multiplayer.multiplayer_peer = peer
	var scene = lobbyScene.instantiate()
	$"/root".add_child(scene)
	hide()
	
func _on_player_connected(id):
	if multiplayer.is_server():
		var unId = multiplayer.get_unique_id()
		print("from %d: Player %d connected" % [unId, id])

func _on_player_disconnected(id):
	print("Player %d disconnected" % id)
	GameManager.players.erase(id)
	player_disconnected.emit(id)

func _on_connected_to_server_ok():
	var unId = multiplayer.get_unique_id()
	var playerName = $Nickname.text
	print("from %d (%s): Connection to server established!" % [unId, playerName])
	add_player_data.rpc_id(1, unId, {"name": playerName})

func _on_connected_to_server_fail():
	print("Connection to server failed!")
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	print("Lost connection to the server!")
	multiplayer.multiplayer_peer = null
	GameManager.players.clear()
	server_disconnected.emit()

@rpc("any_peer", "reliable")
func add_player_data(id, data):
	if not GameManager.players.has(id):
		GameManager.players[id] = data
	if multiplayer.is_server():
		player_connected.emit(id, data)
		for playerId in GameManager.players:
			add_player_data.rpc(playerId, GameManager.players[playerId])
