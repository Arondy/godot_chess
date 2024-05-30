extends Node2D

var cellScene = preload("res://scenes/cell.tscn")

@warning_ignore("integer_division")
func _ready():
	Tools.board = self
	position = Vector2((get_window().size.x - get_window().size.y) / 2, 0)
	create_chessboard()

@warning_ignore("integer_division")
func create_chessboard():
	for row in range(8):
		for col in range(8):
			var cell_y = get_window().size.y / 8
			var cell = cellScene.instantiate()
			cell.name = Tools.int2Let(col + 1) + str(8 - row)
			cell.size = Vector2(cell_y, cell_y)
			cell.position = Vector2(col, row) * cell.size
			if (row + col) % 2 == 0:
				cell.color = Color8(238, 238, 210)
			else:
				cell.color = Color8(118, 150, 86)
			add_child(cell)
