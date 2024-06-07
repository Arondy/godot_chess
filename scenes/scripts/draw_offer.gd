extends Control


func _ready():
	get_tree().paused = true
	#LaterTODO: убрать когда перейдем на fhd
	position = get_window().content_scale_size / 2
	$Panel.size = get_window().content_scale_size / 3
	$Panel.anchors_preset = Control.PRESET_CENTER

func set_text(playerName: String):
	$Panel/Text.text = playerName + " offers you a draw"

func _on_accept_pressed():
	Tools.UI.send_draw_acceptance.rpc()
	Tools.game.finish_game.rpc("[center]Draw[/center]")
	queue_free()

func _on_reject_pressed():
	Tools.UI.send_draw_rejection.rpc()
	get_tree().paused = false
	queue_free()
