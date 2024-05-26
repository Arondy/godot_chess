extends CollisionShape2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var cell_y = get_viewport().size.y / 8
	shape.size = Vector2(cell_y, cell_y)
	position = Vector2(cell_y / 2, cell_y / 2)
