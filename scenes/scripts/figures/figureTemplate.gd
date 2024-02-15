extends Node2D

class_name Figure

var hintScene: PackedScene = preload("res://scenes/hints/common_move_hint.tscn")

@export var fname: String
@export var color: String
@export var cell: Cell
@export var hasCooldown: bool = false

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
	if hasCooldown:
		return
	if event is InputEventMouseButton and Input.is_action_just_pressed("left_mouse"):
		cell.self_modulate = Color8(70, 130, 60, 204)
		$"/root/Game/Figures".currentCellPicked = cell
		
		var hintCells = get_possible_moves()
		print(hintCells)
		for cellName in hintCells:
			var hint = hintScene.instantiate()
			hint.position = $"/root/Game/Board".get_node(cellName).global_position
			$"/root/Game/Hints".add_child(hint)

func _on_selection_cooldown_timeout():
	hasCooldown = false
