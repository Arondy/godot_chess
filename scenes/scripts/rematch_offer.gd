extends Control


func _ready():
	get_tree().paused = true
	#LaterTODO: убрать когда перейдем на fhd
	position = get_window().content_scale_size / 2
	$Panel.size = get_window().content_scale_size / 3
	$Panel.anchors_preset = Control.PRESET_CENTER

func set_text(playerName: String):
	$Panel/Text.text = playerName + " offers you a rematch"

func _on_accept_pressed():
	Tools.UI.send_rematch_acceptance.rpc()
	Tools.start_game.rpc()

func _on_reject_pressed():
	Tools.UI.send_rematch_rejection.rpc()
	get_tree().paused = false
	queue_free()
