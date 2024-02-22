extends Node2D

@export var savePath = "res://saves/check.json"
var saveDict: Dictionary = load_json_file(savePath)
@export var turn: String = saveDict["turn"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

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

func flip_turn():
	if turn == "white":
		turn = "black"
	else:
		turn == "white"

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
	if event is InputEventMouseButton and Input.is_action_just_pressed("left_mouse"):
		if $Figures.currentCellPicked:
			$Figures.currentCellPicked.self_modulate = Color.WHITE
