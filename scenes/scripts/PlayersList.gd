extends TextEdit


func _ready():
	if multiplayer.is_server():
		text += GameManager.players[1]["name"] + "\n"
	else:
		

func _add_player_to_list(peerId, playerInfo):
	text += playerInfo["name"]
