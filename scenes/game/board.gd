extends Node2D

var cellScene = preload("res://scenes/game/cell.tscn")

@warning_ignore("integer_division")
func _ready():
	Tools.board = self
	position = Vector2((get_window().content_scale_size.x - get_window().content_scale_size.y) / 2, 0)
	create_chessboard()

@warning_ignore("integer_division")
func create_chessboard():
	for row in range(8):
		for col in range(8):
			var cellY = get_window().content_scale_size.y / 8
			var cell = cellScene.instantiate()
			cell.name = Tools.int2Let(col + 1) + str(8 - row)
			cell.size = Vector2(cellY, cellY)
			cell.position = Vector2(col, row) * cell.size
			
			if (row + col) % 2 == 0:
				cell.color = Color8(238, 238, 210)
			else:
				cell.color = Color8(118, 150, 86)
				
			add_child(cell)
