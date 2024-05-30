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
			var sFig = src.figure
			
			if (not figure) or sFig.color != figure.color:
				if name in figures.possibleMoves:
					# Common move
					sFig.position = global_position
					change_figure_position.rpc(src.name, name)
					figure.hasCooldown = true
					figure.get_node("Selection_cooldown").start()
					
					# Castle
					if sFig.fname == "king":
						var kingL = src.name.unicode_at(0)
						var newL = name.unicode_at(0)
						var dL = newL - kingL
						
						if abs(dL) == 2:
							change_rook_pos_on_castle(dL, src.name)
					
					#LaterTODO: En passant
					
					end_move(figures)
					Tools.game.clear_hints()
					Tools.figures.currentCellPicked = null

func change_rook_pos_on_castle(dL, srcName):
	var kingL = srcName.unicode_at(0)
	var rD = 3 if (dL > 0) else -4
	var delta = 1 if (dL > 0) else -1
	var rookCellName = char(kingL + rD) + str(srcName)[1]
	var rookSrc = Tools.board.get_node(rookCellName)
	var rook = rookSrc.figure
	var newPos = char(kingL + delta) + str(name)[1]
	rook.position = Tools.board.get_node(newPos).global_position
	change_figure_position.rpc(rookSrc.name, newPos)

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
