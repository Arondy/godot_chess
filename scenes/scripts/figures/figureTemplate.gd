extends Node2D

class_name Figure

var hintScene: PackedScene = preload("res://scenes/hints/common_move_hint.tscn")
var eatHintScene: PackedScene = preload("res://scenes/hints/eat_hint.tscn")

@export var fname: String
@export var color: String
@export var cell: Cell
@export var hasCooldown: bool = false

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
						if (nextLine >= 0 and nextLine < 8 and nextCol >= 0 and nextCol < 8):
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
	if (event is InputEventMouseButton and Input.is_action_just_pressed("left_mouse")
			and get_multiplayer_authority() == multiplayer.get_unique_id()
			and Tools.game.turn == color):
		var figures = Tools.figures
		cell.self_modulate = Color8(70, 130, 60, 204)
		figures.currentCellPicked = cell
		figures.possibleMoves = get_possible_moves(false)
		
		var possibleMoves = figures.possibleMoves
		if not possibleMoves:
			return
			
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
			$"/root/Game/Hints".add_child(hint)

func _on_selection_cooldown_timeout():
	hasCooldown = false
