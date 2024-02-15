extends Sprite2D

func _on_ready():
	centered = false
	scale = $'root/Game/Board'.get_node("A8").size / float(texture.get_height()) / 4
	
