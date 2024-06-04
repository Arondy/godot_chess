extends CollisionShape2D

func _ready():
	var cellY = get_window().content_scale_size.y / 8
	shape.size = Vector2(cellY, cellY)
	position = Vector2(cellY / 2, cellY / 2)
