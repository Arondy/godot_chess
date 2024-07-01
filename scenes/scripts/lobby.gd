extends Control

var soundScene = preload("res://scenes/sound.tscn")
@onready var debug = multiplayer.get_unique_id()
var address: String

func _ready():
	var sound = soundScene.instantiate()
	$/root.add_child.call_deferred(sound)
	Tools.sound = sound
	
	if multiplayer.is_server():
		$/root/Multiplayer.player_connected.connect(_on_player_connected)
		address = IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")), IP.TYPE_IPV4)
		$HBox/IP.text = "Your IP: %s" % address
	else:
		$HBox.visible = false

func _on_launch_game_pressed():
	print("Connected peers: ", multiplayer.get_peers())
	if multiplayer.get_peers():
		Tools.start_game.rpc(true)

func _on_player_connected(_id, _data):
	$"VBox/Change color".disabled = false

func _on_copy_pressed():
	DisplayServer.clipboard_set(address)
