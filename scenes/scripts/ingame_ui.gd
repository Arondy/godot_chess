extends Control

var drawOfferScene = preload("res://scenes/UI/draw_offer.tscn")
var rematchOfferScene = preload("res://scenes/UI/rematch_offer.tscn")
var lastMove: String = ""

func _ready():
	Tools.UI = self
	for id in GameManager.players:
		var pname = GameManager.players[id]["name"]
		
		if id  == multiplayer.get_unique_id():
			$"Panel/Right panel/My name".text = pname
		else:
			$"Panel/Right panel/Opponent name".text = pname

#TODO: норм прокрут до конца
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
	$"Panel/Right panel/History/Grid".add_child(move)
	await get_tree().process_frame
	var scroll = $"Panel/Right panel/History".get_v_scroll_bar()
	scroll.value = scroll.max_value

func _on_draw_pressed():
	send_draw_offer.rpc()
	get_tree().paused = true
	
func _on_resign_pressed():
	var textForOp = "[center]Opponent resigned[/center]"
	var myText = "[center]You resigned[/center]"
	Tools.game.finish_game.rpc(textForOp, myText)
	get_tree().paused = true

@rpc("any_peer", "reliable")
func send_draw_offer():
	var scene = drawOfferScene.instantiate()
	var senderId = multiplayer.get_remote_sender_id()
	scene.set_text(GameManager.players[senderId]["name"])
	add_child(scene)

@rpc("any_peer", "reliable")
func send_draw_rejection():
	var senderId = multiplayer.get_remote_sender_id()
	var senderName = GameManager.players[senderId]["name"]
	$"Panel/Right panel/Notifications".text = senderName + " rejected your draw offer"
	get_tree().paused = false
	
@rpc("any_peer", "reliable")
func send_draw_acceptance():
	var senderId = multiplayer.get_remote_sender_id()
	var senderName = GameManager.players[senderId]["name"]
	$"Panel/Right panel/Notifications".text = senderName + " accepted your draw offer"


@rpc("any_peer", "reliable")
func send_rematch_offer():
	var scene = rematchOfferScene.instantiate()
	var senderId = multiplayer.get_remote_sender_id()
	scene.set_text(GameManager.players[senderId]["name"])
	add_child(scene)

@rpc("any_peer", "reliable")
func send_rematch_rejection():
	var senderId = multiplayer.get_remote_sender_id()
	var senderName = GameManager.players[senderId]["name"]
	$"Panel/Right panel/Notifications".text = senderName + " rejected your rematch offer"
	get_tree().paused = false

@rpc("any_peer", "reliable")
func send_rematch_acceptance():
	var senderId = multiplayer.get_remote_sender_id()
	var senderName = GameManager.players[senderId]["name"]
	$"Panel/Right panel/Notifications".text = senderName + " accepted your rematch offer"
