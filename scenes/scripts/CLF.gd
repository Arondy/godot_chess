extends CanvasLayer

func _ready():
	if $"..".myColor == "black":
		var oY = get_window().size.y / 8
		offset = get_window().size - Vector2i(oY, oY)
		rotation = PI
