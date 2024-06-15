extends Node2D

func _ready():
	if multiplayer.is_server():
		var address = IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")), IP.TYPE_IPV4)
		$IP.text = "Your IP: %s" % address
		print($IP.text)

func _on_launch_game_pressed():
	print("Connected peers: ", multiplayer.get_peers())
	if multiplayer.get_peers():
		Tools.start_game.rpc(true)
