extends Figure

func get_possible_moves() -> Array:
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
		get_line_moves(direction, res)
	
	for direction in rookDirections:
		get_line_moves(direction, res)
	
	return res
