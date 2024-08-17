extends Control

var drawOfferScene: PackedScene = preload("res://scenes/UI/draw_offer.tscn")
var rematchOfferScene: PackedScene = preload("res://scenes/UI/rematch_offer.tscn")
var lastMove: String = ""
var deltaTime: int = 0
@onready var _RPanel: VBoxContainer = $"Panel/Margin/Right panel"
@onready var _myTime: Label = _RPanel.get_node("My time")
@onready var _myTimer: Timer = _myTime.get_node("Timer")
@onready var _myName: Label = _RPanel.get_node("My name")
@onready var _opTime: Label = _RPanel.get_node("Opponent time")
@onready var _opTimer: Timer = _opTime.get_node("Timer")
@onready var _opName: Label = _RPanel.get_node("Opponent name")
@onready var _notify: RichTextLabel = _RPanel.get_node("Notifications")
@onready var _drawButton: Button = _RPanel.get_node("Margin2/HBox/Draw")

@warning_ignore("integer_division")
func _ready():
	position.y = get_window().content_scale_size.y / 2
	Tools.UI = self
	var _game = $/root/Game
	var timeArray = _game.saveDict["clock"]
	deltaTime = timeArray[2]
	
	for id in Tools.players:
		var pname = Tools.players[id]["name"]
		
		if id  == multiplayer.get_unique_id():
			_myName.text = pname
		else:
			_opName.text = pname
		
	if Tools.myColor == "white":
		_myTimer.wait_time = timeArray[0]
		_opTimer.wait_time = timeArray[1]
	else:
		_myTimer.wait_time = timeArray[1]
		_opTimer.wait_time = timeArray[0]
		
	if Tools.myColor == _game.turn:
		_opTimer.paused = true
	else:
		_myTimer.paused = true
		
	_myTimer.start()
	_opTimer.start()

func _process(_delta):
	_myTime.text = "%02d:%02d" % [_myTimer.time_left / 60, int(_myTimer.time_left) % 60]
	_opTime.text = "%02d:%02d" % [_opTimer.time_left / 60, int(_opTimer.time_left) % 60]

@rpc("any_peer", "call_local", "reliable")
func write_to_history(figName: String, srcCellName: String,
		newCellName: String, hasEaten: bool, check: bool, castle: int, promotion: String):
	var text
	var name2Let = {
		"pawn" = srcCellName[0].to_lower() if hasEaten else "",
		"knight" = "N",
		"bishop" = "B",
		"rook" = "R",
		"queen" = "Q",
		"king" = "K"
	}
	
	var move = Label.new()
	move.custom_minimum_size = Vector2(70, 30)
	
	if castle:
		text = "O-O" if castle == 2 else "O-O-O"
	else:
		text = name2Let[figName]
		
		if hasEaten:
			text += "x"
			
		text += newCellName.to_lower()
	
		if promotion:
			text += ("=" + promotion[0].to_upper())
			
	if check:
		text += "+"
		
	lastMove = text
	move.text = text
	var history = $"Panel/Margin/Right panel/Margin/History"
	history.get_node("Grid").add_child(move)
	
	var scroll = history.get_v_scroll_bar()
	await scroll.changed
	history.scroll_vertical = scroll.max_value

func _on_draw_pressed():
	send_offer.rpc("draw")
	_drawButton.disabled = true
	get_tree().paused = true
	
func _on_resign_pressed():
	var textForOp = "[center]Opponent resigned[/center]"
	var myText = "[center]You resigned[/center]"
	Tools.game.finish_game.rpc(textForOp, myText)
	get_tree().paused = true

@rpc("any_peer", "reliable")
func send_offer(offer: String):
	var scene: Node
	
	if offer == "draw":
		scene = drawOfferScene.instantiate()
	elif offer == "rematch":
		scene = rematchOfferScene.instantiate()
	else:
		return
	
	var senderId = multiplayer.get_remote_sender_id()
	scene.set_text(Tools.players[senderId]["name"])
	add_child(scene)

@rpc("any_peer", "reliable")
func send_offer_rejection(offer: String):
	var senderId = multiplayer.get_remote_sender_id()
	var senderName = Tools.players[senderId]["name"]
	
	_notify.text = senderName + " rejected your %s offer" % offer
	_notify.get_node("Timer").start()
	get_tree().paused = false

@rpc("any_peer", "call_local", "reliable")
func flip_clocks():
	_myTimer.paused = not _myTimer.paused
	_opTimer.paused = not _opTimer.paused
	
	if multiplayer.get_unique_id() == multiplayer.get_remote_sender_id():
		_myTimer.wait_time = _myTimer.time_left + deltaTime
		_myTimer.start()
	else:
		_opTimer.wait_time = _opTimer.time_left + deltaTime
		_opTimer.start()

func _on_opTimer_timeout():
	var textForOp = "[center]Your time ran out[/center]"
	var myText = "[center]Opponent's time ran out[/center]"
	Tools.game.finish_game.rpc(textForOp, myText)
	get_tree().paused = true

func _on_myTimer_timeout():
	var textForOp = "[center]Opponent's time ran out[/center]"
	var myText = "[center]Your time ran out[/center]"
	Tools.game.finish_game.rpc(textForOp, myText)
	get_tree().paused = true

func _on_notify_timer_timeout():
	_notify.visible = false
