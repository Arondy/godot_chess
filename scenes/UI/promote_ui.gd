extends Control

signal promotion_figure_selected(figureName: String)

func _ready():
	get_tree().paused = true

func set_color(color: String):
	var queen = $VBox/Queen
	var rook = $VBox/Rook
	var bishop = $VBox/Bishop
	var knight = $VBox/Knight
	var buttons = [queen, rook, bishop, knight]
	var fig2str = {
		queen: "queen",
		rook: "rook", 
		bishop: "bishop",
		knight: "knight"
	}
	var minButtonSize = Tools.board.get_node("A8").size
	
	for fig in buttons:
		fig.custom_minimum_size = minButtonSize
		fig.icon = load("res://textures/figures/%s_%s.png" % [fig2str[fig], color])
	
func _on_queen_pressed():
	promotion_figure_selected.emit("res://scenes/figures/queen.tscn")
	get_tree().paused = false

func _on_rook_pressed():
	promotion_figure_selected.emit("res://scenes/figures/rook.tscn")
	get_tree().paused = false

func _on_bishop_pressed():
	promotion_figure_selected.emit("res://scenes/figures/bishop.tscn")
	get_tree().paused = false

func _on_knight_pressed():
	promotion_figure_selected.emit("res://scenes/figures/knight.tscn")
	get_tree().paused = false

func _unhandled_input(event):
	if event is InputEventMouseButton and Input.is_action_just_pressed("_perform_action"):
		promotion_figure_selected.emit("")
		get_tree().paused = false
		queue_free()
