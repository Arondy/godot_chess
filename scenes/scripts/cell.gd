extends ColorRect

class_name Cell

var figure: Figure
var promoteScene = preload("res://scenes/promote_ui.tscn")
signal promotion_finished

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

		if (src and ((not figure) or src.figure.color != figure.color)
				and name in figures.possibleMoves):
			var sFig = src.figure
			var sFigName = sFig.fname
			var hasEaten: bool = (figure != null)
			var castle: int = 0
			var promotion = ""
			
			# Common move
			sFig.position = global_position
			change_figure_position.rpc(src.name, name)
			figure.hasCooldown = true
			figure.get_node("Selection_cooldown").start()
			
			# Castle
			if sFigName == "king":
				var dC = name.unicode_at(0) - src.name.unicode_at(0)
				
				if abs(dC) == 2:
					play_castle_sound.rpc()
					change_rook_pos_on_castle(dC, src.name)
					castle = 2 if (dC > 0) else 3
			
			# En passant
			elif sFigName == "pawn":
				var dC = name.unicode_at(0) - src.name.unicode_at(0)
				
				if abs(dC) == 1 and not hasEaten:
					hasEaten = not hasEaten
					var EPCellName = str(name)[0] + str(src.name)[1]
					remove_figure.rpc(EPCellName)
			
				# Promote
				var dL = name.unicode_at(1) - src.name.unicode_at(1)
				
				if abs(dL) == 1 and str(name)[1] in ["1", "8"]:
					add_promote_ui()
					get_tree().paused = true
					await promotion_finished
					figures.currentCellPicked.self_modulate = Color.WHITE
					get_tree().paused = false
					#LaterTODO: изменить, когда можно будет отменять promote (мб на bool, фигуру можно понять по name)
					promotion = figure.fname
			
			figures.checkThreats.clear()
			figures.fill_attacked_info(Tools.getOpColor(figure.color))
			var check = not figures.checkThreats.is_empty()
			
			end_move(figures)
			Tools.game.clear_hints()
			Tools.UI.write_to_history.rpc(sFigName, src.name, name, hasEaten, check, castle, promotion)
			Tools.game.get_state.rpc()

func change_rook_pos_on_castle(dC, srcName):
	var kingL = srcName.unicode_at(0)
	var rD = 3 if (dC > 0) else -4
	var delta = 1 if (dC > 0) else -1
	var rookCellName = char(kingL + rD) + str(srcName)[1]
	var rookSrc = Tools.board.get_node(rookCellName)
	var rook = rookSrc.figure
	var newPos = char(kingL + delta) + str(name)[1]
	rook.position = Tools.board.get_node(newPos).global_position
	change_figure_position.rpc(rookSrc.name, newPos)

@rpc("any_peer", "call_local", "reliable")
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
	
@rpc("any_peer", "call_local", "reliable")
func change_figure_position(srcName: String, newCellName: String):
	var board = Tools.board
	var src = board.get_node(srcName)
	var newCell = board.get_node(newCellName)
	src.figure.cell = board.get_node(newCellName)
	
	if newCell.figure:
		remove_figure(newCellName)
	else:
		$"Common move".play()
		
	newCell.figure = src.figure
	src.figure = null
	
	var fig = newCell.figure
	
	if fig.fname in ["king", "rook"]:
		if not fig.hasMoved:
			fig.hasMoved = true
			
		if fig.fname == "king":
			Tools.figures.kingsPosition[fig.color] = newCell

@rpc("any_peer", "call_local", "reliable")
func remove_figure(cellName: String):
	$Eat.play()
	var cell = Tools.board.get_node(cellName)
	cell.figure.queue_free()
	cell.figure = null

@rpc("any_peer", "call_local", "reliable")
func play_castle_sound():
	$Castle.play()

func add_promote_ui():
	var scene = promoteScene.instantiate()
	scene.position = global_position
	Tools.game.add_child(scene)
	scene.set_color(Tools.game.turn)
	scene.promotion_figure_selected.connect(_on_promotion_choice)
	
func _on_promotion_choice(pathToScene: String):
	Tools.game.get_node("Promote UI").queue_free()
	remove_figure.rpc(name)
	promote.rpc(pathToScene)
	promotion_finished.emit()

@rpc("any_peer", "call_local", "reliable")
func promote(pathToScene: String):
	var promFig = load(pathToScene).instantiate()
	promFig.color = Tools.game.turn
	promFig.cell = self
	Tools.figures.set_figure_image(promFig)
	promFig.position = global_position
	figure = promFig
	Tools.figures.get_node(promFig.color).add_child(promFig)
