extends ColorRect

var figure: Figure

func has_friendly_figure(figureColor) -> bool:
	if figure and figure.color == figureColor:
		return true
	return false

func has_enemy_figure(figureColor) -> bool:
	if figure and figure.color != figureColor:
		return true
	return false
