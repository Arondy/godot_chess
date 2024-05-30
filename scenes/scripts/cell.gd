extends ColorRect

class_name Cell

var figure: Figure

func has_friendly_figure(figureColor: String) -> bool:
	if figure and figure.color == figureColor:
		return true
	return false

func has_enemy_figure(figureColor: String) -> bool:
	if figure and figure.color != figureColor:
		return true
	return false
	
func has_figure() -> bool:
	return figure != null

func _on_making_move(event):
	if event is InputEventMouseButton and Input.is_action_just_pressed("left_mouse"):
		var figures = Tools.figures
		var src = figures.currentCellPicked
		
		if src:
			if (not figure) or src.figure.color != figure.color:
				if name in figures.possibleMoves:
					
					# Common move
					src.figure.position = global_position
					change_figure_position.rpc(src.name, name)
					figure.hasCooldown = true
					figure.get_node("Selection_cooldown").start()
					
					#TODO: castle
					
					end_move(figures)
					
			clear_hints(figures, src)

@rpc("any_peer", "reliable", "call_local")
func flip_turn():
	var game = Tools.game
	game.turn = "black" if (game.turn == "white") else "white"

func end_move(figures: Object):
	flip_turn.rpc()
	figures.examine_check.rpc()
	figures.checkThreats.clear()
	figures.threatMoves.clear()
	figures.firstFigsOnLine.clear()
	figures.attackedMask.clear()

func clear_hints(figures: Object, src: Cell):
	figures.currentCellPicked = null
	figures.possibleMoves.clear()
	src.self_modulate = Color.WHITE
	
	var hints = $"/root/Game/Hints"
	for child in hints.get_children():
		hints.remove_child(child)
	
@rpc("any_peer", "reliable", "call_local")
func change_figure_position(srcName: String, newCellName: String):
	var board = Tools.board
	var src = board.get_node(srcName)
	var newCell = board.get_node(newCellName)
	src.figure.cell = board.get_node(newCellName)
	
	if newCell.figure:
		newCell.figure.free()
		
	newCell.figure = src.figure
	src.figure = null
	
	var fig = newCell.figure
	
	if fig.fname in ["king", "rook"]:
		if not fig.hasMoved:
			fig.hasMoved = true
			
		if fig.fname == "king":
			Tools.figures.kingsPosition[fig.color] = newCell
