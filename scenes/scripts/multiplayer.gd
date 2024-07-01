extends Control

signal player_connected(peerId, playerInfo)

var lobbyScene: PackedScene = preload("res://scenes/lobby.tscn")
var peer = ENetMultiplayerPeer.new()
@export var adress: String = "127.0.0.1"
@export var port: int = 8080
var nickname: Object
var ip: Object
var notify: Object

func _ready():
	nickname = $HBox/Margin/VBox/Nickname
	ip = $HBox/Margin/VBox/IP
	notify = $HBox/Margin/VBox/Notification
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.connected_to_server.connect(_on_connected_to_server_ok)
	multiplayer.connection_failed.connect(_on_connected_to_server_fail)
	load_net_cfg()

func load_net_cfg():
	var cfgPath = Tools.cfgFilePath
	
	if FileAccess.file_exists(cfgPath):
		var err = Tools.config.load(cfgPath)

		if err != OK:
			return
			
		nickname.text = Tools.config.get_value("net", "nickname")
		ip.text = Tools.config.get_value("net", "ip")

func save_net_cfg():
	var cfgPath = Tools.cfgFilePath
	
	Tools.config.set_value("net", "nickname", nickname.text)
	#if not multiplayer.is_server():
	Tools.config.set_value("net", "ip", ip.text)
	Tools.config.save(cfgPath)
	
func check_name() -> bool:
	if nickname.text:
		return true
	else:
		notify.text = "[center]You must input a valid name![/center]"
		return false

func check_ip() -> bool:
	if ip.text and ip.text.is_valid_ip_address():
		adress = ip.text
		return true
	else:
		notify.text = "[center]You must input a valid IP address![/center]"
		return false

func _on_host_button_pressed():
	var error = peer.create_server(port, 2)
	
	if error:
		return error
		
	if OS.has_feature("release"):
		if not check_name():
			return
	
	save_net_cfg()
	
	multiplayer.multiplayer_peer = peer
	add_player_data(multiplayer.get_unique_id(), {"name": nickname.text})
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
	
func _on_player_connected(id):
	if multiplayer.is_server():
		var unId = multiplayer.get_unique_id()
		print("from %d: Player %d connected" % [unId, id])

func _on_connected_to_server_ok():
	var scene = lobbyScene.instantiate()
	$"/root".add_child(scene)
	hide()
	
	var unId = multiplayer.get_unique_id()
	var playerName = nickname.text
	print("from %d (%s): Connection to server established!" % [unId, playerName])
	add_player_data.rpc_id(1, unId, {"name": playerName})

func _on_connected_to_server_fail():
	print("Connection to server failed!")
	multiplayer.multiplayer_peer = null

@rpc("any_peer", "reliable")
func add_player_data(id, data):
	if not Tools.players.has(id):
		Tools.players[id] = data
	if multiplayer.is_server():
		player_connected.emit(id, data)
		for playerId in Tools.players:
			add_player_data.rpc(playerId, Tools.players[playerId])
