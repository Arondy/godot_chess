extends CanvasLayer

@warning_ignore("integer_division")
func _ready():
	if Tools.myColor == "black":
		var oY = get_window().size.y / 8
		offset = get_window().size - Vector2i(oY, oY)
		rotation = PI
