extends Node

var game: Object
var board: Object
var figures: Object


func uNum2int(unicode: int) -> int:
	return unicode - 48

func uLet2int(unicode: int) -> int:
	return unicode - 64

func int2Let(unicode: int) -> String:
	return char(unicode + 64)

func getOpColor(color: String) -> String:
	var opColor = "black" if (color == "white") else "white"
	return opColor

func load_mp3(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var sound = AudioStreamMP3.new()
	sound.data = file.get_buffer(file.get_length())
	return sound
