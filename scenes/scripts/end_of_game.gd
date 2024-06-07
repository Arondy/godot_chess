extends Control

func _ready():
	get_tree().paused = true
	#LaterTODO: убрать когда перейдем на fhd
	position = get_window().content_scale_size / 2
	$Panel.size = get_window().content_scale_size / 3
	$Panel.anchors_preset = Control.PRESET_CENTER

func _on_exit_pressed():
	var startingScene = load("res://scenes/multiplayer.tscn")
	get_tree().paused = false
	multiplayer.multiplayer_peer.close()
	get_tree().change_scene_to_packed(startingScene)

func _on_rematch_pressed():
	Tools.UI.send_rematch_offer.rpc()
