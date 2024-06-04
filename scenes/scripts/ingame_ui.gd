extends Control

var lastMove: String = ""

func _ready():
	Tools.UI = self
	for id in GameManager.players:
		var pname = GameManager.players[id]["name"]
		
		if id  == multiplayer.get_unique_id():
			$"Panel/Right panel/My name".text = pname
		else:
			$"Panel/Right panel/Opponent name".text = pname

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
