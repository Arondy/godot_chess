extends Node2D


var gameScene: PackedScene = preload("res://scenes/game.tscn")

func _on_launch_game_pressed():
	print(multiplayer.get_peers())
	if not multiplayer.get_peers().size():
		return
	get_tree().change_scene_to_packed(gameScene)
