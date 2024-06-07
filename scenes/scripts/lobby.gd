extends Node2D

func _on_launch_game_pressed():
	print("Connected peers: ", multiplayer.get_peers())
	if multiplayer.get_peers():
		Tools.start_game.rpc()
