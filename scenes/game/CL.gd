extends CanvasLayer

@warning_ignore("integer_division")
func _ready():
	if Tools.myColor == "black":
		offset = get_window().content_scale_size
		rotation = PI
