extends Figure

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
	
	return res
