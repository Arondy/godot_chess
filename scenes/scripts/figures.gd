extends Node2D

var pawnScene: PackedScene = preload("res://scenes/figures/pawn.tscn")
var knightScene: PackedScene = preload("res://scenes/figures/knight.tscn")
var bishopScene: PackedScene = preload("res://scenes/figures/bishop.tscn")
var rookScene: PackedScene = preload("res://scenes/figures/rook.tscn")
var queenScene: PackedScene = preload("res://scenes/figures/queen.tscn")
var kingScene: PackedScene = preload("res://scenes/figures/king.tscn")

@export var currentCellPicked: ColorRect
@export var possibleMoves: Array
@export var kingsPosition: Dictionary
@export var attackedMask: Array[String] = []
@export var checkThreats: Array[Figure] = []
@export var threatMoves: Array[String]
@export var firstFigsOnLine: Dictionary

#LaterTODO: переворот борды и фигур для black игрока
func _ready():
	Tools.figures = self
	load_position($"..".saveDict)
	$"/root/Game".myColor = "white" if multiplayer.is_server() else "black"
	
	if $"/root/Game".myColor == $"/root/Game".turn:
		examine_check()

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

func set_king_info(figureScene: Figure, boardCell: Cell):
	kingsPosition[figureScene.color] = boardCell
	if ((figureScene.color == "white" and boardCell.name != "E1") or
			(figureScene.color == "black" and boardCell.name != "E8")):
		figureScene.hasMoved = true

func set_rook_info(figureScene: Figure, boardCell: Cell):
	if ((figureScene.color == "white" and (boardCell.name not in ["A1", "H1"])) or
			(figureScene.color == "black" and (boardCell.name not in ["A8", "H8"]))):
		figureScene.hasMoved = true

func load_position(dict):
	if dict and dict["field"]:
		var saveStr = dict["field"]
		for row in range(8):
			for col in range(8):
				var c = saveStr[row * 8 + col]
				if c != '/':
					var figureScene = create_figure_by_letter(c)
					var cell_name = str(char(65 + col)) + str(8 - row)
					var boardCell = Tools.board.get_node(cell_name)
					figureScene.position = boardCell.global_position
					figureScene.cell = boardCell
					
					if figureScene.fname == "king":
						set_king_info(figureScene, boardCell)
					elif figureScene.fname == "rook":
						set_rook_info(figureScene, boardCell)
						
					get_node(figureScene.color).add_child(figureScene)
					boardCell.figure = figureScene
		
		if (multiplayer.is_server()):
			rpc("setup_player_team", "white", multiplayer.get_unique_id())
			rpc("setup_player_team", "black", multiplayer.get_peers()[0])

@rpc("authority", "call_local", "reliable")
func setup_player_team(team, peer):
	get_node(team).set_multiplayer_authority(peer)

@rpc("any_peer", "reliable")
func examine_check():
	fill_attacked_info()
	
	if checkThreats:
		get_allowed_moves_during_check()
		
	get_first_figures_on_attack_lines()
	
func fill_attacked_info():
	var color = $"..".turn
	var kingPos = Tools.board.get_node(str(kingsPosition[color]))
	var opColor = Tools.getOpColor(color)
	var figures = get_node(opColor).get_children()
		
	for figure in figures:
		var attMoves = figure.get_possible_moves(true)
		
		if kingPos.name in attMoves:
			checkThreats.append(figure)
			
		for move in attMoves:
			if move not in attackedMask:
				attackedMask.append(move)

func get_allowed_moves_during_check():
	if checkThreats.size() == 1:
		var threat = checkThreats[0]
		var threatCell = threat.cell
		var kingPos = kingsPosition[$"..".turn]
		var tL = threatCell.name.unicode_at(0)
		var tN = threatCell.name.unicode_at(1)
		var kL = kingPos.name.unicode_at(0)
		var kN = kingPos.name.unicode_at(1)
		
		if threat.fname in ["bishop", "rook", "queen"]:
			var lineDiff = abs(tN - kN)
			var colDiff = abs(tL - kL)
			var dL = 0 if (lineDiff == 0) else (1 if (tN < kN) else -1)
			var dC = 0 if (colDiff == 0) else (1 if (tL < kL) else -1)
			var i = Tools.uLet2int(tL)
			var j = Tools.uNum2int(tN)
			
			while (i != Tools.uLet2int(kL)) or (j != Tools.uNum2int(kN)):
				var cellName = Tools.int2Let(i) + str(j)
				threatMoves.append(cellName)
				i += dC
				j += dL
		else:
			threatMoves.append(threatCell.name)

func get_first_figures_on_attack_lines():
	var color = $"..".turn
	var kingPos = kingsPosition[color]
	var opColor = Tools.getOpColor(color)
	
	for enemy in get_node(opColor).get_children():
		if enemy.fname not in ["bishop", "rook", "queen"]:
			continue
			
		var enemyCell = enemy.cell
		var tL = enemyCell.name.unicode_at(0)
		var tN = enemyCell.name.unicode_at(1)
		var kL = kingPos.name.unicode_at(0)
		var kN = kingPos.name.unicode_at(1)
		var lineDiff = abs(tN - kN)
		var colDiff = abs(tL - kL)

		var isDiagonal: bool = abs(lineDiff) == abs(colDiff)
		var isOrthogonal: bool = (lineDiff == 0 and colDiff != 0) or (lineDiff != 0 and colDiff == 0)
		
		if ((enemy.fname == "bishop" and isDiagonal) or
				(enemy.fname == "rook" and isOrthogonal) or
				(enemy.fname == "queen" and (isDiagonal or isOrthogonal))):
			var movesOnLine = [enemyCell.name]
			var dL = 0 if (lineDiff == 0) else (1 if (tN < kN) else -1)
			var dC = 0 if (colDiff == 0) else (1 if (tL < kL) else -1)
			var i = Tools.uLet2int(tL) + dC
			var j = Tools.uNum2int(tN) + dL
			
			while (i != Tools.uLet2int(kL)) or (j != Tools.uNum2int(kN)):
				var cellName = Tools.int2Let(i) + str(j)
				movesOnLine.append(cellName)
				var figOnLine = $"../Board".get_node(cellName).figure
				
				if figOnLine:
					if figOnLine.color == color:
						firstFigsOnLine[figOnLine] = movesOnLine
					break
				i += dC
				j += dL
