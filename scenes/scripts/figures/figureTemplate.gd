extends Node2D

class_name Figure

var hintScene: PackedScene = preload("res://scenes/hints/common_move_hint.tscn")

@export var fname: String
@export var color: String
@export var cell: Cell
@export var hasCooldown: bool = false

func get_line_moves(direction: Array, pMoves: Array, forKing: bool):
	var line
	var column
	var cname = cell.name
	var dL = direction[1]
	var dC = direction[0]
	
	for i in range(1, 8):
		line = cname.unicode_at(1) - "0".unicode_at(0) + i * dL
		column = cname.unicode_at(0) - "@".unicode_at(0) + i * dC
		
		if line >= 1 and column >= 1 and line <= 8 and column <= 8:
			var move = char(column + "@".unicode_at(0)) + str(line)
			var bcell = $"/root/Game/Board".get_node(move)
			if bcell.has_figure():
				if bcell.has_friendly_figure(color) and not forKing:
					break
				else:
					pMoves.append(move)
					break
			pMoves.append(move)
		else:
			break	

func onCheck_move_checkup():
	pass
	
func onAttackLine_move_checkup():
	pass
	
func whoseTurn_move_checkup():
	pass
	
func check_move(dest: String, forKing: bool) -> bool:
	return false
	
func get_possible_moves(forKing: bool) -> Array:
	return []

func _on_figure_area_2d_input_event(viewport, event, shape_idx):
	if hasCooldown:
		return
	if event is InputEventMouseButton and Input.is_action_just_pressed("left_mouse"):
		cell.self_modulate = Color8(70, 130, 60, 204)
		$"/root/Game/Figures".currentCellPicked = cell
		$"/root/Game/Figures".possibleMoves = get_possible_moves(false)
		
		var possibleMoves = $"/root/Game/Figures".possibleMoves
		if not possibleMoves:
			return
			
		for cellName in possibleMoves:
			var hint = hintScene.instantiate()
			var cellEl = $"/root/Game/Board".get_node(cellName)
			hint.position = cellEl.global_position + Vector2(cellEl.size) / 2
			hint.scale = cellEl.size / float(hint.texture.get_height()) / 4
			$"/root/Game/Hints".add_child(hint)

func _on_selection_cooldown_timeout():
	hasCooldown = false
