extends Control

signal promotion_figure_selected(figureName: String)

func set_color(color: String):
	var queen = $Panel/VBox/Queen
	var rook = $Panel/VBox/Rook
	var bishop = $Panel/VBox/Bishop
	var knight = $Panel/VBox/Knight
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

func _on_rook_pressed():
	promotion_figure_selected.emit("res://scenes/figures/rook.tscn")

func _on_bishop_pressed():
	promotion_figure_selected.emit("res://scenes/figures/bishop.tscn")

func _on_knight_pressed():
	promotion_figure_selected.emit("res://scenes/figures/knight.tscn")
