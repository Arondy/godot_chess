extends Figure

func check_move(dest: String):
	var cellName: String = cell.name
	var srcCell1 = cellName.unicode_at(0)
	var srcCell2 = cellName.unicode_at(1)
	var dx: int = dest.unicode_at(1) - srcCell2
	var dy: int = dest.unicode_at(0) - srcCell1
	
	# Первый ход (на две клетки вперёд)
	if cellName[1] == "2" and color == "white":
		var dCellName1 = char(srcCell1) + char(srcCell2 + 1)
		var dCellName2 = char(srcCell1) + char(srcCell2 + 2)
		if dx == 2 and dy == 0 and not $"/root/Game/Board".get_node(dCellName1).has_figure() and not $"/root/Game/Board".get_node(dCellName2).has_figure():
			return true
	elif cellName[1] == "7" and color == "black":
		var dCellName1 = char(srcCell1) + char(srcCell2 - 1)
		var dCellName2 = char(srcCell1) + char(srcCell2 - 2)
		if dx == -2 and dy == 0 and not $"/root/Game/Board".get_node(dCellName1).has_figure() and not $"/root/Game/Board".get_node(dCellName2).has_figure():
			return true
	
	# Обычный ход вперёд
	if color == "white":
		var dCellName1 = char(srcCell1) + char(srcCell2 + 1)
		if dx == 1 and dy == 0 and not $"/root/Game/Board".get_node(dCellName1).has_figure():
			return true
	else:
		var dCellName1 = char(srcCell1) + char(srcCell2 - 1)
		if dx == -1 and dy == 0 and not $"/root/Game/Board".get_node(dCellName1).has_figure():
			return true
	
	# Съедение
	if color == "white":
		var dCellName1 = char(srcCell1) + char(srcCell2 + 1)
		if dx == 1 and abs(dy) == 1 and $"/root/Game/Board".get_node(dCellName1).has_enemy_figure(color):
			return true
	else:
		var dCellName1 = char(srcCell1) + char(srcCell2 - 1)
		if dx == -1 and abs(dy) == 1 and $"/root/Game/Board".get_node(dCellName1).has_enemy_figure(color):
			return true
			
	# En passant
	
	
	return false
	
	
func get_possible_moves() -> Array:
	var res = []
	var baseStr = cell.name
	var char1 = baseStr.unicode_at(0)
	var char2 = baseStr.unicode_at(1)
	
	if color == "white":
		res = [
			char(char1) + char(char2 + 1),
			char(char1) + char(char2 + 2),
			char(char1 + 1) + char(char2 + 1),
			char(char1 - 1) + char(char2 + 1)
		]
	else:
		res = [
			char(char1) + char(char2 - 1),
			char(char1) + char(char2 - 2),
			char(char1 + 1) + char(char2 - 1),
			char(char1 - 1) + char(char2 - 1)
		]
	print(res)
	for cellName in res:
		if not check_move(cellName):
			res.erase(cellName)
	print(res)
	return res
