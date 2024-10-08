extends Figure

func get_possible_moves(forKing: bool) -> Array:
	var res = []
	var bishopDirections = [
		[-1, -1],
		[-1, 1],
		[1, -1],
		[1, 1]
	]
	var rookDirections = [
		[-1, 0],
		[1, 0],
		[0, -1],
		[0, 1]
	]
	
	for direction in bishopDirections:
		get_line_moves(direction, res, forKing)
	
	for direction in rookDirections:
		get_line_moves(direction, res, forKing)
	
	if not forKing:
		res = get_moves_on_check(res)
		res = get_moves_on_attack_line(res)
	
	return res
