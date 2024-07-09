extends Dialog

func set_text(playerName: String):
	get_text_node().text = playerName + " offers you a draw"

func _on_accept_pressed():
	Tools.game.finish_game.rpc("[center]Draw[/center]")
	queue_free()

func _on_reject_pressed():
	Tools.UI.send_offer_rejection.rpc("draw")
	get_tree().paused = false
	queue_free()
