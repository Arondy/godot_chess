extends Figure

func check_move(dest: String, forKing: bool) -> bool:
	var cellName: String = cell.name
	var srcCh1 = cellName.unicode_at(0)
	var srcCh2 = cellName.unicode_at(1)
	var dy: int = dest.unicode_at(1) - srcCh2
	var dx: int = dest.unicode_at(0) - srcCh1
	
	if dest[0] > "H" or dest[1] > "8" or dest[0] < "A" or dest[1] < "1":
		return false

	if (not $"/root/Game/Board".get_node(dest).has_friendly_figure(color)
			or forKing):
		if abs(dx) == 2 and abs(dy) == 1:
			return true
		if abs(dx) == 1 and abs(dy) == 2:
			return true
	
	return false

func get_possible_moves(forKing: bool) -> Array:
	var res = []
	var baseStr: String = cell.name
	var char1 = baseStr.unicode_at(0)
	var char2 = baseStr.unicode_at(1)
	
	var pMoves = [
		char(char1 + 1) + char(char2 + 2),
		char(char1 + 1) + char(char2 - 2),
		char(char1 - 1) + char(char2 + 2),
		char(char1 - 1) + char(char2 - 2),
		char(char1 + 2) + char(char2 + 1),
		char(char1 + 2) + char(char2 - 1),
		char(char1 - 2) + char(char2 + 1),
		char(char1 - 2) + char(char2 - 1)
	]
	
	for cellName in pMoves:
		if check_move(cellName, forKing):
			res.append(cellName)
	
	return res
