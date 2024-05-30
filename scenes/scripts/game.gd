extends Node2D

@export var savePath = "res://saves/test.json"
var saveDict: Dictionary = load_json_file(savePath)
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
	if event is InputEventMouseButton and Input.is_action_just_pressed("left_mouse"):
		if $Figures.currentCellPicked:
			$Figures.currentCellPicked.self_modulate = Color.WHITE
