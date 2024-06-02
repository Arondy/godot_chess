extends Node2D

@export var savePath = "res://saves/check.json"
var saveDict: Dictionary = load_json_file(savePath)
var endScene = preload("res://scenes/end_of_game.tscn")
@export var turn: String = saveDict["turn"]
@export var myColor: String
@export var debug: int


func _ready():
	Tools.game = self
	debug = multiplayer.get_unique_id()

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

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
	elif event is InputEventMouseButton and Input.is_action_just_pressed("left_mouse"):
		if $Figures.currentCellPicked:
			var figure = $Figures.currentCellPicked.figure
			figure.hasCooldown = true
			figure.get_node("Selection_cooldown").start()
			clear_hints()

func clear_hints():
	$Figures.currentCellPicked.self_modulate = Color.WHITE
	$Figures.currentCellPicked = null
	$Figures.possibleMoves.clear()
	
	for child in $Hints.get_children():
		child.free()

func noMoveAvailable() -> bool:
	var figures = $Figures.get_node(turn).get_children()
		
	for figure in figures:
		var moves = figure.get_possible_moves(false)
		if moves:
			return false
	
	return true

func get_state():
	if noMoveAvailable():
		var text
		
		if $Figures.checkThreats:
			text = "[center][b]Mate[/b][/center]"
		else:
			text = "[center][b]Stalemate[/b][/center]"
			
		send_results_to_peers.rpc(text)

@rpc("any_peer", "call_local", "reliable")
func send_results_to_peers(text: String):
	var endMessage = endScene.instantiate()
	var textNode = endMessage.get_node("ReferenceRect").get_node("Text")
	
	textNode.text = text
	add_child.call_deferred(endMessage)
	$"Game over".play()
