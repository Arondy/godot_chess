extends Figure

func check_move(dest: String) -> bool:
	var cellName: String = cell.name
	var srcCh1 = cellName.unicode_at(0)
	var srcCh2 = cellName.unicode_at(1)
	var dy: int = dest.unicode_at(1) - srcCh2
	var dx: int = dest.unicode_at(0) - srcCh1
	var srchDy1
	var srchDy2
	var dCellName1
	var dCellName2
	
	if color == "white":
		srchDy1 = 1
		srchDy2 = 2
	else:
		srchDy1 = -1
		srchDy2 = -2
	
	if dest[0] > "H" or dest[1] > "8" or dest[0] < "A" or dest[1] < "1":
		return false
	
	# Первый ход (на две клетки вперёд)
	dCellName1 = char(srcCh1) + char(srcCh2 + srchDy1)
	dCellName2 = char(srcCh1) + char(srcCh2 + srchDy2)
	if dy == srchDy2 and dx == 0 and not $"/root/Game/Board".get_node(dCellName1).has_figure() and not $"/root/Game/Board".get_node(dCellName2).has_figure():
		if cellName[1] == "2" and color == "white":
			return true
		elif cellName[1] == "7" and color == "black":
			return true
	
	# Обычный ход вперёд
	if dy == srchDy1 and dx == 0 and not $"/root/Game/Board".get_node(dCellName1).has_figure():
		return true
	
	# Съедение
	if dy == srchDy1 and abs(dx) == 1:
		dCellName1 = char(srcCh1 + dx) + char(srcCh2 + srchDy1)
		
		if $"/root/Game/Board".get_node(dCellName1).has_enemy_figure(color):
			return true
	
	# En passant
	
	return false
	
	
func get_possible_moves() -> Array:
	var res = []
	var pMoves = []
	var baseStr = cell.name
	var char1 = baseStr.unicode_at(0)
	var char2 = baseStr.unicode_at(1)
	var dy1
	var dy2
	
	if color == "white":
		dy1 = 1
		dy2 = 2
	else:
		dy1 = -1
		dy2 = -2
		
	pMoves = [
		char(char1) + char(char2 + dy1),
		char(char1) + char(char2 + dy2),
		char(char1 + 1) + char(char2 + dy1),
		char(char1 - 1) + char(char2 + dy1)
	]

	for cellName in pMoves:
		if check_move(cellName):
			res.append(cellName)

	return res
