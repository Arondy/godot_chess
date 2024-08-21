extends Node2D

class_name Figure

var hintScene: PackedScene = preload("res://scenes/hints/common_move_hint.tscn")
var eatHintScene: PackedScene = preload("res://scenes/hints/eat_hint.tscn")

@export var fname: String
@export var color: String
@export var cell: Cell
@export var hasCooldown: bool = false
var draggable: bool = false
@onready var _hints: Node2D = $/root/Game/CL/Hints

func get_line_moves(direction: Array, pMoves: Array, forKing: bool):
	var cname = cell.name
	var dL = direction[1]
	var dC = direction[0]
	
	for i in range(1, 8):
		var line = Tools.uNum2int(cname.unicode_at(1)) + i * dL
		var column = Tools.uLet2int(cname.unicode_at(0)) + i * dC
		
		if line >= 1 and column >= 1 and line <= 8 and column <= 8:
			var move = Tools.int2Let(column) + str(line)
			var bcell = Tools.board.get_node(move)
			if bcell.has_figure():
				if bcell.has_friendly_figure(color) and not forKing:
					break
				else:
					pMoves.append(move)
					var figure = Tools.board.get_node(move).figure
					if (forKing and figure.fname == "king" and figure.color != color):
						var nextLine = line + dL
						var nextCol = column + dC
						if (nextLine >= 1 and nextLine <= 8 and nextCol >= 1 and nextCol <= 8):
							pMoves.append(Tools.int2Let(nextCol) + str(nextLine))
					break
			pMoves.append(move)
		else:
			break	

func get_moves_on_check(pMoves: Array) -> Array:
	if not Tools.figures.checkThreats:
		return pMoves
	
	var res = []
	
	for move in Tools.figures.threatMoves:
		if move in pMoves:
			res.append(move)
	
	return res

func get_moves_on_attack_line(pMoves: Array) -> Array:
	var res = []
	var lineFigs = Tools.figures.firstFigsOnLine
	
	if not (self in lineFigs.keys()):
		return pMoves
		
	for move in lineFigs[self]:
		if move in pMoves:
			res.append(move)
	
	return res
	
@warning_ignore("unused_parameter")
func check_move(dest: String, forKing: bool) -> bool:
	return false
	
@warning_ignore("unused_parameter")
func get_possible_moves(forKing: bool) -> Array:
	return []

func _on_figure_selection(_viewport, event, _shape_idx):
	if hasCooldown:
		return
	elif (event is InputEventMouseButton and Input.is_action_just_pressed("_perform_action")
			and get_multiplayer_authority() == multiplayer.get_unique_id()
			and Tools.game.turn == color):
		
		if Tools.figures.currentCellPicked == cell:
			Tools.game.clear_hints()
			return
			
		var figures = Tools.figures
		cell.self_modulate = Color8(70, 130, 60, 204)
		figures.currentCellPicked = cell
		figures.possibleMoves = get_possible_moves(false)
		
		var possibleMoves = figures.possibleMoves
		#if not possibleMoves:
			#return
			
		for cellName in possibleMoves:
			var cellEl = Tools.board.get_node(str(cellName))
			var hint
			
			if cellEl.figure:
				hint = eatHintScene.instantiate()
				hint.scale = cellEl.size / float(hint.texture.get_height())
			else:
				hint = hintScene.instantiate()
				hint.scale = cellEl.size / float(hint.texture.get_height()) / 4
				
			hint.position = cellEl.global_position + Vector2(cellEl.size) / 2
			_hints.add_child(hint)

func _on_selection_cooldown_timeout():
	hasCooldown = false

@warning_ignore("integer_division")
func _unhandled_input(event):
	if (get_multiplayer_authority() != multiplayer.get_unique_id()
			or Tools.myColor != Tools.game.turn):
		return
	
	var windowY = get_window().content_scale_size.y
	var figureHalf = windowY / 16
	var boardOffsetX = Tools.board.global_position.x
	var boardSize = Vector2(windowY, windowY)
	var offset = Vector2(figureHalf, figureHalf)
	
	if color == "black":
		offset *= -1
	
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("_perform_action"):
			var figPos = (global_position if color == "white"
				else boardSize + Vector2(boardOffsetX * 2, 0) - global_position)
			var rect = abs(event.position - figPos - offset)
			
			if rect.x < figureHalf and rect.y < figureHalf:
				draggable = true
				
		elif Input.is_action_just_released("_perform_action") and draggable:
			var col = int(event.position.x - boardOffsetX) / (windowY / 8)
			var row = int(event.position.y) / (windowY / 8)
			
			if color == "black":
				col = 7 - col
				row = 7 - row
				
			draggable = false
			
			if col < 0 or col > 7 or row < 0 or row > 7:
				return
				
			var cell_name = Tools.int2Let(col + 1) + str(8 - row)
			var madeMove = await Tools.board.get_node(cell_name).make_move()
			
			if not madeMove and global_position != cell.global_position:
				global_position = cell.global_position
				Tools.game.clear_hints()
			
	elif event is InputEventMouseMotion and draggable:
		if color == "white":
			global_position = event.position - offset
		else:
			global_position = boardSize + Vector2(boardOffsetX * 2, 0) - (event.position - offset)
