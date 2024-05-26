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

func _on_gui_input(event):
	if event is InputEventMouseButton and Input.is_action_just_pressed("left_mouse"):
		var src = $"/root/Game/Figures".currentCellPicked
		if src:
			if (not figure) or (figure and src.figure.color != figure.color):
				if name in $"/root/Game/Figures".possibleMoves:
					src.figure.position = global_position
					src.figure.cell = self
					figure = src.figure
					src.figure = null
					figure.hasCooldown = true
					if multiplayer.is_server():
						flip_turn()
					else:
						rpc_id(1, "flip_turn")
					figure.get_node("Selection_cooldown").start()
					
			$"/root/Game/Figures".currentCellPicked = null
			$"/root/Game/Figures".possibleMoves.clear()
			src.self_modulate = Color.WHITE
			
			var hints = $"/root/Game/Hints"
			for child in hints.get_children():
				hints.remove_child(child)

@rpc("any_peer", "reliable")
func flip_turn():
	if $"/root/Game".turn == "white":
		$"/root/Game".turn = "black"
	else:
		$"/root/Game".turn = "white"
	if multiplayer.is_server():
		flip_turn.rpc()
