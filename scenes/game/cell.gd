extends ColorRect

class_name Cell

signal promotion_finished(successful)

var figure: Figure
var promoteScene: PackedScene = preload("res://scenes/UI/promote_ui.tscn")
var checkHintScene: PackedScene = preload("res://scenes/hints/check_hint.tscn")

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
		make_move()

func make_move() -> bool:
	var figures = Tools.figures
	var src = figures.currentCellPicked

	if not (src and ((not figure) or src.figure.color != figure.color)
			and name in figures.possibleMoves):
		return false
		
	var sFig = src.figure
	var sFigName = sFig.fname
	var hasEaten: bool = (figure != null)
	var castle: int = 0
	var promotion = ""
	
	# Castle
	if sFigName == "king":
		var dC = name.unicode_at(0) - src.name.unicode_at(0)
		
		if abs(dC) == 2:
			play_castle_sound.rpc()
			change_rook_pos_on_castle(dC, src.name)
			castle = 2 if (dC > 0) else 3
	
	elif sFigName == "pawn":
		# En passant
		var dC = name.unicode_at(0) - src.name.unicode_at(0)
		
		if abs(dC) == 1 and not hasEaten:
			hasEaten = not hasEaten
			var EPCellName = str(name)[0] + str(src.name)[1]
			remove_figure.rpc(EPCellName)

		# Promote
		var dL = name.unicode_at(1) - src.name.unicode_at(1)
		
		if abs(dL) == 1 and str(name)[1] in ["1", "8"]:
			add_promote_ui()
			var successful = await promotion_finished
			src.self_modulate = Color.WHITE

			if not successful:
				Tools.game.clear_hints()
				return false

			remove_figure.rpc(src.name)
			promotion = figure.fname
			
	if not promotion:
		# Common move
		change_figure_position.rpc(src.name, name)
		figure.hasCooldown = true
		figure.get_node("Selection_cooldown").start()
	
	if figures.checkThreats:
		clear_check_hint.rpc()
	
	figures.checkThreats.clear()
	var opColor = Tools.getOpColor(figure.color)
	figures.fill_attacked_info(opColor)
	var check = not figures.checkThreats.is_empty()
	
	if check:
		add_check_hint.rpc(opColor, src.size)
	
	end_move(figures)
	Tools.game.clear_hints()
	Tools.UI.write_to_history.rpc(sFigName, src.name, name, hasEaten, check, castle, promotion)
	Tools.game.get_state.rpc()
	return true

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
	Tools.UI.flip_clocks.rpc()
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
	src.figure.cell = newCell
	
	if newCell.figure:
		remove_figure(newCellName)
	else:
		Tools.sound.get_node("Common move").play()
		
	newCell.figure = src.figure
	src.figure = null
	newCell.figure.global_position = newCell.global_position
	
	var fig = newCell.figure
	
	if fig.fname in ["king", "rook"]:
		if not fig.hasMoved:
			fig.hasMoved = true
			
		if fig.fname == "king":
			Tools.figures.kingsPosition[fig.color] = newCell

@rpc("any_peer", "call_local", "reliable")
func remove_figure(cellName: String):
	var cell = Tools.board.get_node(cellName)
	
	if cell.figure:
		Tools.sound.get_node("Eat").play()
		cell.figure.queue_free()
		cell.figure = null

@rpc("any_peer", "call_local", "reliable")
func play_castle_sound():
	Tools.sound.get_node("Castle").play()

func add_promote_ui():
	var scene = promoteScene.instantiate()
	scene.position = global_position
	scene.set_color(Tools.game.turn)
	await get_tree().process_frame
	Tools.game.add_child(scene)
	scene.promotion_figure_selected.connect(_on_promotion_choice)
	
func _on_promotion_choice(pathToScene: String):
	if pathToScene:
		Tools.game.get_node("Promote UI").queue_free()
		remove_figure.rpc(name)
		promote.rpc(pathToScene)

	var successful = true if pathToScene else false
	promotion_finished.emit(successful)

@rpc("any_peer", "call_local", "reliable")
func promote(pathToScene: String):
	var promFig = load(pathToScene).instantiate()
	promFig.color = Tools.game.turn
	promFig.cell = self
	Tools.figures.set_figure_image(promFig)
	promFig.position = global_position
	figure = promFig
	promFig.set_multiplayer_authority(multiplayer.get_remote_sender_id())
	
	if Tools.myColor == "black":
		figure.get_node("Image").flip_v = true
		figure.get_node("Image").flip_h = true
		
	Tools.figures.get_node(promFig.color).add_child(promFig, true)

@rpc("any_peer", "call_local", "reliable")
func add_check_hint(opColor: String, cellSize: Vector2i):
	var scene = checkHintScene.instantiate()
	scene.position = Tools.figures.kingsPosition[opColor].global_position
	scene.scale = cellSize / float(scene.texture.get_height())
	$"/root/Game/CL/Check hint".add_child(scene)

@rpc("any_peer", "call_local", "reliable")
func clear_check_hint():
	for child in $"/root/Game/CL/Check hint".get_children():
		child.queue_free()
