extends Figure

func check_move(dest):
	var dx: int = dest[0] - cell[0]
	var dy: int = dest[1] - cell[1]
	var dict = {
		"s_white": 2,
		"s_black": 6,
		"dx_white": -2,
		"dx_black": 2,
	}
	# Первый ход (на две клетки вперёд)
	if cell[1] == dict["s_" + color]:
		pass
	
