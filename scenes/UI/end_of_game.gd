extends Dialog

func _on_exit_pressed():
	var startingScene = load("res://scenes/onscreen scenes/multiplayer.tscn")
	Tools.players.clear()
	get_tree().paused = false
	multiplayer.multiplayer_peer.close()
	get_tree().change_scene_to_packed(startingScene)

func _on_rematch_pressed():
	Tools.UI.send_offer.rpc("rematch")
	get_right_button().disabled = true
