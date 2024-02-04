extends Node2D

class_name Figure

@export var color: String
@export var cell: String

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func onCheck_move_checkup():
	pass
	
func onAttackLine_move_checkup():
	pass
	
func whoseTurn_move_checkup():
	pass
	
func check_move(dest):
	pass
	
func get_possible_moves():
	pass

func _on_figure_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and Input.is_action_just_pressed("select"):
		var gameCell = $"/root/Game/Board".get_node(cell)
		gameCell.self_modulate = Color8(70, 130, 60, 204)
		$"/root/Game/Figures".currentCellPicked = gameCell
