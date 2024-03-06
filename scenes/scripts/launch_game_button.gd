extends Button


func _ready():
	if not multiplayer.is_server():
		disabled = true
