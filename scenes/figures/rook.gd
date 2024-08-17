extends Figure

var hasMoved: bool = false

func get_possible_moves(forKing: bool) -> Array:
	var res = []
	var directions = [
		[-1, 0],
		[1, 0],
		[0, -1],
		[0, 1]
	]
	
	for direction in directions:
		get_line_moves(direction, res, forKing)
	
	if not forKing:
		res = get_moves_on_check(res)
		res = get_moves_on_attack_line(res)
	
	return res
