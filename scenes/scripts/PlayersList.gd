extends TextEdit


func _ready():
	if multiplayer.is_server():
		get_node("/root/Multiplayer").player_connected.connect(_add_player_to_list)
		text += GameManager.players[1]["name"]
		
func _add_player_to_list(_peerId, playerInfo):
	text += "\n" + playerInfo["name"]
