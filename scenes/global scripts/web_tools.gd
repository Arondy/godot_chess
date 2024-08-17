extends Node

func _ready():
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		multiplayer.multiplayer_peer.close()
	
func _on_peer_disconnected(id: int):
	print("From %d: Player %d disconnected" % [multiplayer.get_unique_id(), id])
	Tools.players.erase(id)
	var notification_ = load("res://scenes/UI/player_disconnection_notification.tscn")
	var scene = notification_.instantiate()
	Tools.UI.add_child(scene)
	#player_disconnected.emit(id)

func _on_server_disconnected():
	print("The server disconnected!")
	multiplayer.multiplayer_peer.close()
	Tools.players.clear()
	#server_disconnected.emit()
