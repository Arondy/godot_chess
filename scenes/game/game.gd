extends Control

@export var savePath: String = "res://saves/mate.json"
var saveDict: Dictionary = load_json_file(savePath)
var endScene: PackedScene = preload("res://scenes/UI/end_of_game.tscn")
@export var turn: String = saveDict["turn"]
@onready var _figures: Node2D = $CL/Figures
@onready var _hints: Node2D = $CL/Hints
@onready var debug: int = multiplayer.get_unique_id()

func _ready():
	Tools.game = self

func load_json_file(path: String):
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		
		if data is Dictionary:
			return data
		else:
			print("Wrong format in \"%s\"!" % path)
	else:
		print("File \"%s\" doesn't exist!" % path)

func clear_hints():
	if _figures.currentCellPicked:
		_figures.currentCellPicked.self_modulate = Color.WHITE
		_figures.currentCellPicked = null
	_figures.possibleMoves.clear()

	for child in _hints.get_children():
		child.free()

func no_move_available() -> bool:
	var opFigures = Tools.figures.get_node(turn).get_children()
		
	for figure in opFigures:
		var moves = figure.get_possible_moves(false)
		if moves:
			return false
	
	return true

@rpc("any_peer", "reliable")
func get_state():
	if no_move_available():
		var text
		
		if _figures.checkThreats:
			text = "[center][b]Mate[/b][/center]"
		else:
			text = "[center][b]Stalemate[/b][/center]"
			
		finish_game.rpc(text)

@rpc("any_peer", "call_local", "reliable")
func finish_game(text: String, text2: String = ""):
	var endMessage = endScene.instantiate()
	var textNode = endMessage.get_text_node()
	
	if text2 and multiplayer.get_remote_sender_id() == multiplayer.get_unique_id():
		textNode.text = text2
	else:
		textNode.text = text
		
	Tools.UI.add_child.call_deferred(endMessage)
	Tools.sound.get_node("Game over").play()

func _unhandled_input(event):
	if event is InputEventMouseButton and Input.is_action_just_pressed("_perform_action"):
		if not _figures.currentCellPicked:
			return
			
		var figure = _figures.currentCellPicked.figure

		if figure:
			figure.hasCooldown = true
			figure.get_node("Selection_cooldown").start()
		clear_hints()
