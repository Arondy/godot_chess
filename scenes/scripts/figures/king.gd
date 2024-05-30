extends Figure

var hasMoved = false

func king_check_move(dest: String, attackedMask: Array) -> bool:
	var cellName: String = cell.name
	var srcCh1 = cellName.unicode_at(0)
	var srcCh2 = cellName.unicode_at(1)
	var dy: int = dest.unicode_at(1) - srcCh2
	var dx: int = dest.unicode_at(0) - srcCh1
	
	if dest[0] > "H" or dest[1] > "8" or dest[0] < "A" or dest[1] < "1":
		return false
	
	if (abs(dx) > 1 || abs(dy) > 1 || cellName == dest
			or Tools.board.get_node(dest).has_friendly_figure(color)):
		return false
	
	return dest not in attackedMask

func addCastleMove(pRook, cells, mask, board, res):
	if pRook and pRook.fname == "rook" and pRook.color == color and (not pRook.hasMoved):
		
		for cell_ in cells:
			if cell_ in mask or board.get_node(cell_).has_figure():
				return
		
		res.append(cells[0])

func get_castle_moves() -> Array:
	var res = []
	
	if hasMoved or Tools.figures.checkThreats:
		return res
	
	var num: String = "1" if (color == "white") else "8"
	var cellsOO = ["G" + num, "F" + num]
	var cellsOOO = ["C" + num, "D" + num, "B" + num]
	var mask = Tools.figures.attackedMask
	var board = Tools.board
	var pRookOO = board.get_node("H" + num).figure
	var pRookOOO = board.get_node("A" + num).figure
	
	addCastleMove(pRookOO, cellsOO, mask, board, res)
	addCastleMove(pRookOOO, cellsOOO, mask, board, res)
	
	return res

func get_possible_moves(forKing: bool) -> Array:
	var res = []
	var cellName: String = cell.name
	var srcCh1 = cellName.unicode_at(0)
	var srcCh2 = cellName.unicode_at(1)
	var mask = []
	
	if not forKing:
		mask = Tools.figures.attackedMask
		var castleMoves = get_castle_moves()
		res.append_array(castleMoves)
	
	for i in range(-1, 2):
		for j in range(-1, 2):
			var move = char(srcCh1 + i) + char(srcCh2 + j)
			if king_check_move(move, mask):
				res.append(move)

	return res
