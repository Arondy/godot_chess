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

func _on_gui_input(event):
	if event is InputEventMouseButton and Input.is_action_just_pressed("left_mouse"):
		var src = $"/root/Game/Figures".currentCellPicked
		if src:
			if (not figure) or (figure && src.figure.color != figure.color):
				# move_check
				src.figure.position = global_position
				src.figure.cell = name
				figure = src.figure
				src.figure = null
				figure.hasCooldown = true
				figure.get_node("Selection_cooldown").start()
			$"/root/Game/Figures".currentCellPicked = null
			src.self_modulate = Color.WHITE
			
