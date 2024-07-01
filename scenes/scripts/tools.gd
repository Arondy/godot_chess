extends Node

var players = {}
var gameScene: PackedScene = preload("res://scenes/game.tscn")
var gameStartSound = preload("res://audio/start.mp3")
var soundPlayer: AudioStreamPlayer
var game: Object
var board: Object
var figures: Object
var UI: Object
var sound: Object
var cfgFilePath: String = "user://auto.cfg"
var config = ConfigFile.new()
var myColor: String

#func _ready():
	#soundPlayer = AudioStreamPlayer.new()
	#soundPlayer.stream = gameStartSound
	#$/root.add_child.call_deferred(soundPlayer)
	
@rpc("any_peer", "call_local", "reliable")
func start_game(fromLobby: bool):
	#soundPlayer.play()
	$"/root/Sound/Game start".play()
	get_tree().paused = false
	
	if fromLobby:
		myColor = "black" if $"/root/Lobby/VBox/Change color".button_pressed else "white"
		$/root/Lobby.queue_free()
		
	get_tree().change_scene_to_packed(gameScene)
	
func uNum2int(unicode: int) -> int:
	return unicode - 48

func uLet2int(unicode: int) -> int:
	return unicode - 64

func int2Let(unicode: int) -> String:
	return char(unicode + 64)

func getOpColor(color: String) -> String:
	var opColor = "black" if (color == "white") else "white"
	return opColor
