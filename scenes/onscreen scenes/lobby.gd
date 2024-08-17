extends Control

var _address: String
@onready var _ip: RichTextLabel = $HBox/IP
@onready var _changeColorButton: Button = $"VBox/Change color"
@onready var _notification: Label = $Notification

func _ready():
	if multiplayer.is_server():
		$/root/Multiplayer.player_connected.connect(_on_player_connected)
		_address = IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")), IP.TYPE_IPV4)
		_ip.text = "Your IP: %s" % _address
	else:
		$"Start game".disabled = true
		$HBox.visible = false

func _on_start_game_pressed():
	print("Connected peers: ", multiplayer.get_peers())
	if multiplayer.get_peers():
		Tools.start_game.rpc(true)

func _on_player_connected(_id, _data):
	_changeColorButton.disabled = false

func _on_copy_pressed():
	DisplayServer.clipboard_set(_address)
	_notification.visible = true
	_notification.get_node("Timer").start()

func _on_timer_timeout():
	_notification.visible = false

func _shortcut_input(_event):
	if Input.is_action_just_pressed("start_game"):
		_on_start_game_pressed()
