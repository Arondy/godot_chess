extends VBoxContainer

func _ready():
	if multiplayer.is_server():
		$"/root/Multiplayer".player_connected.connect(_synchronise_player_list)
		var label = Label.new()
		label.text = Tools.players[multiplayer.get_unique_id()]["name"]
		add_child(label)

func _synchronise_player_list(peerId, playerInfo):
	for player in Tools.players:
		if player != peerId:
			add_player_to_list.rpc_id(peerId, Tools.players[player])
	add_player_to_list.rpc(playerInfo)

@rpc("authority", "call_local", "reliable")
func add_player_to_list(playerInfo):
	var label = Label.new()
	label.text = playerInfo["name"]
	add_child(label)
