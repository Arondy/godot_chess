extends Node2D

var pawnScene: PackedScene = preload("res://scenes/figures/pawn.tscn")
var knightScene: PackedScene = preload("res://scenes/figures/knight.tscn")
var bishopScene: PackedScene = preload("res://scenes/figures/bishop.tscn")
var rookScene: PackedScene = preload("res://scenes/figures/rook.tscn")
var queenScene: PackedScene = preload("res://scenes/figures/queen.tscn")
var kingScene: PackedScene = preload("res://scenes/figures/king.tscn")
@export var currentCellPicked: ColorRect
@export var kingsPosition: Dictionary
@export var checkThreats: Array[Figure]

func _ready():
	load_position($"/root/Game".saveDict)

func set_figure_image(figureScene):
	var texturePath = "res://textures/figures/%s_%s.png" % [figureScene.name.to_lower(), figureScene.color]
	var image = figureScene.get_node("Image")
	image.texture = load(texturePath)
	image.scale = $'../Board'.get_node("A8").size / float(image.texture.get_height())
	image.centered = false

func create_figure_by_letter(letter):
	var letterToFigure = {
		'P': ["pawn",   "white"],
		'N': ["knight", "white"],
		'B': ["bishop", "white"],
		'R': ["rook",   "white"],
		'Q': ["queen",  "white"],
		'K': ["king",   "white"],
		'p': ["pawn",   "black"],
		'n': ["knight", "black"],
		'b': ["bishop", "black"],
		'r': ["rook",   "black"],
		'q': ["queen",  "black"],
		'k': ["king",   "black"],
	}
	var figure = letterToFigure[letter]
	var figureScene
	
	match figure[0]:
		"pawn":
			figureScene = pawnScene.instantiate()
		"knight":
			figureScene = knightScene.instantiate()
		"bishop":
			figureScene = bishopScene.instantiate()
		"rook":
			figureScene = rookScene.instantiate()
		"queen":
			figureScene = queenScene.instantiate()
		"king":
			figureScene = kingScene.instantiate()
			
	figureScene.fname = figure[0]
	figureScene.color = figure[1]
	set_figure_image(figureScene)
	return figureScene

func load_position(dict):
	if dict and dict["field"]:
		var saveStr = dict["field"]
		for row in range(8):
			for col in range(8):
				var c = saveStr[row * 8 + col]
				if c != '/':
					var figureScene = create_figure_by_letter(c)
					var cell_name = str(char(65 + col)) + str(8 - row)
					var boardCell = $"/root/Game/Board".get_node(cell_name)
					figureScene.position = boardCell.global_position
					figureScene.cell = boardCell
					if figureScene.fname == "king":
						kingsPosition[figureScene.color] = boardCell
					add_child(figureScene)
					boardCell.figure = figureScene

func examine_check():
	var kingPos = kingsPosition[$"/root/Game".turn]
	for figure in $"/root/Game/Figures".get_children():
		if (figure.color != $"/root/Game".turn and figure.fname != "king" 
				and kingPos in figure.get_possible_moves(false)):
			checkThreats.append(figure)
