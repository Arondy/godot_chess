extends Figure

func check_move(dest: String, forKing: bool) -> bool:
	var cellName: String = cell.name
	var srcCh1 = cellName.unicode_at(0)
	var srcCh2 = cellName.unicode_at(1)
	var dy: int = dest.unicode_at(1) - srcCh2
	var dx: int = dest.unicode_at(0) - srcCh1
	
	if dest[0] > "H" or dest[1] > "8" or dest[0] < "A" or dest[1] < "1":
		return false

	if abs(dx) != abs(dy):
		return false
		
	var deltaL = 1 if dy > 0 else -1
	var deltaC = 1 if dx > 0 else -1
	var j = srcCh1 + deltaC
	
	for i in range(srcCh2 + deltaL, dest.unicode_at(1), deltaL):
		var el = char(j) + char(i)
		if Tools.board.get_node(el).has_figure():
			return false
		j += deltaC
	
	if not cell.has_friendly_figure(color):
		return true
		
	return false

func get_possible_moves(forKing: bool) -> Array:
	var res = []
	var directions = [
		[-1, -1],
		[-1, 1],
		[1, -1],
		[1, 1]
	]
	
	for direction in directions:
		get_line_moves(direction, res, forKing)
	
	if not forKing:
		res = get_moves_on_check(res)
		res = get_moves_on_attack_line(res)
	
	return res
