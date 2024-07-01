extends Control

var drawOfferScene = preload("res://scenes/UI/draw_offer.tscn")
var rematchOfferScene = preload("res://scenes/UI/rematch_offer.tscn")
var lastMove: String = ""
var deltaTime: int = 0
var myTime: Timer
var opTime: Timer
var notify: RichTextLabel

@warning_ignore("integer_division")
func _ready():
	position.y = get_window().content_scale_size.y / 2
	Tools.UI = self
	var game = $/root/Game
	myTime = $"Panel/Margin/Right panel/My time/Timer"
	opTime = $"Panel/Margin/Right panel/Opponent time/Timer"
	notify = $"Panel/Margin/Right panel/Notifications"
	var timeArray = game.saveDict["clock"]
	deltaTime = timeArray[2]
	
	for id in Tools.players:
		var pname = Tools.players[id]["name"]
		
		if id  == multiplayer.get_unique_id():
			$"Panel/Margin/Right panel/My name".text = pname
		else:
			$"Panel/Margin/Right panel/Opponent name".text = pname
		
	if Tools.myColor == "white":
		myTime.wait_time = timeArray[0]
		opTime.wait_time = timeArray[1]
	else:
		myTime.wait_time = timeArray[1]
		opTime.wait_time = timeArray[0]
		
	if Tools.myColor == game.turn:
		opTime.paused = true
	else:
		myTime.paused = true
		
	myTime.start()
	opTime.start()

func _process(_delta):
	var myTimeStr = $"Panel/Margin/Right panel/My time"
	var opTimeStr = $"Panel/Margin/Right panel/Opponent time"
	myTimeStr.text = "%02d:%02d" % [myTime.time_left / 60, int(myTime.time_left) % 60]
	opTimeStr.text = "%02d:%02d" % [opTime.time_left / 60, int(opTime.time_left) % 60]

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
	$"Panel/Margin/Right panel/Margin2/HBox/Draw".disabled = true
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
	
	notify.text = senderName + " rejected your %s offer" % offer
	notify.get_node("Timer").start()
	get_tree().paused = false

@rpc("any_peer", "call_local", "reliable")
func flip_clocks():
	myTime.paused = not myTime.paused
	opTime.paused = not opTime.paused
	
	if multiplayer.get_unique_id() == multiplayer.get_remote_sender_id():
		myTime.wait_time = myTime.time_left + deltaTime
		myTime.start()
	else:
		opTime.wait_time = opTime.time_left + deltaTime
		opTime.start()

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
	$"Panel/Margin/Right panel/Notifications".visible = false
