extends Control

signal player_connected(peerId, playerInfo)

var lobbyScene: PackedScene = preload("res://scenes/onscreen scenes/lobby.tscn")
var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

@export var adress: String = "127.0.0.1"
@export var port: int = 8080
@onready var _nickname: LineEdit = $HBox/Margin/VBox/Nickname
@onready var _ip: LineEdit = $HBox/Margin/VBox/IP
@onready var _notification: RichTextLabel = $HBox/Margin/VBox/Notification

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.connected_to_server.connect(_on_connected_to_server_ok)
	multiplayer.connection_failed.connect(_on_connected_to_server_fail)
	load_net_cfg()

func load_net_cfg():
	_nickname.text = Tools.config.get_value("net", "nickname", "")
	_ip.text = Tools.config.get_value("net", "ip", "")

func save_net_cfg():
	var cfg = Tools.config
	cfg.set_value("net", "nickname", _nickname.text)
	cfg.set_value("net", "ip", _ip.text)
	cfg.save(Tools.cfgFilePath)
	
func check_name() -> bool:
	if _nickname.text:
		return true
	else:
		_notification.text = "[center]You must input a valid name![/center]"
		return false

func check_ip() -> bool:
	if _ip.text and _ip.text.is_valid_ip_address():
		adress = _ip.text
		return true
	else:
		_notification.text = "[center]You must input a valid IP address![/center]"
		return false

func _on_host_button_pressed():
	multiplayer.multiplayer_peer.close()
	
	if OS.has_feature("release"):
		if not check_name():
			return
	
	var error = peer.create_server(port, 2)
	
	if error == ERR_CANT_CREATE:
		_notification.text = "[center]Lobby have already been hosted![/center]"

	if error:
		return error
	
	save_net_cfg()
	
	multiplayer.multiplayer_peer = peer
	add_player_data(multiplayer.get_unique_id(), {"name": _nickname.text})
	var scene = lobbyScene.instantiate()
	$"/root".add_child(scene)
	hide()
	print("Host is waiting for players...")

func _on_join_button_pressed():
	multiplayer.multiplayer_peer.close()
	
	if OS.has_feature("release"):
		if not (check_name() and check_ip()):
			return
	
	var error = peer.create_client(adress, port)
	
	if error:
		return error
	
	save_net_cfg()
	
	multiplayer.multiplayer_peer = peer
	_notification.text = "[center]Connecting to host...[/center]"
	
func _on_player_connected(id: int):
	if multiplayer.is_server():
		var unId = multiplayer.get_unique_id()
		print("from %d: Player %d connected" % [unId, id])

func _on_connected_to_server_ok():
	var scene = lobbyScene.instantiate()
	$"/root".add_child(scene)
	hide()
	
	var unId = multiplayer.get_unique_id()
	var playerName = _nickname.text
	print("from %d (%s): Connection to server established!" % [unId, playerName])
	add_player_data.rpc_id(1, unId, {"name": playerName})

func _on_connected_to_server_fail():
	print("Connection to server failed!")
	_notification.text = "[center]Connection to server failed![/center]"
	multiplayer.multiplayer_peer.close()

@rpc("any_peer", "reliable")
func add_player_data(id: int, data: Dictionary):
	if not Tools.players.has(id):
		Tools.players[id] = data
	if multiplayer.is_server():
		player_connected.emit(id, data)
		for playerId in Tools.players:
			add_player_data.rpc(playerId, Tools.players[playerId])

func _shortcut_input(_event):
	if Input.is_action_just_pressed("_host_game"):
		_on_host_button_pressed()
	elif Input.is_action_just_pressed("_join_game"):
		_on_join_button_pressed()
