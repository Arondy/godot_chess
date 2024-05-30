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
