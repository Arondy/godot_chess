extends Control

@warning_ignore("integer_division")
func _ready():
	get_tree().paused = true
	position.x = get_window().content_scale_size.x / -2

func _on_exit_pressed():
	var startingScene = load("res://scenes/onscreen scenes/multiplayer.tscn")
	Tools.players.clear()
	get_tree().paused = false
	multiplayer.multiplayer_peer.close()
	get_tree().change_scene_to_packed(startingScene)
