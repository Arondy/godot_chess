extends Dialog

func set_text(playerName: String):
	get_text_node().text = playerName + " offers you a rematch"

func _on_accept_pressed():
	Tools.start_game.rpc(false)

func _on_reject_pressed():
	Tools.UI.send_offer_rejection.rpc("rematch")
	get_tree().paused = false
	queue_free()
