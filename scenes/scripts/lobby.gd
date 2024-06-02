extends Node2D


var gameScene: PackedScene = preload("res://scenes/game.tscn")

func _on_launch_game_pressed():
	print("Connected peers: ", multiplayer.get_peers())
	if not multiplayer.get_peers().size():
		return
	rpc("start_game")

@rpc("authority", "call_local", "reliable")
func start_game():
	hide()
	get_tree().change_scene_to_packed(gameScene)
	$"Game start".play()
