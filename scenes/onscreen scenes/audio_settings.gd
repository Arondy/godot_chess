extends Control

@onready var _VBox: VBoxContainer = $Margin/VBox
@onready var _music: HBoxContainer = $Margin/VBox/Music
@onready var _sounds: HBoxContainer = $Margin/VBox/Sounds
var musicBusIndex: int = AudioServer.get_bus_index("Music")
var soundsBusIndex: int = AudioServer.get_bus_index("Sounds")

func _ready():
	load_cfg_values()

func load_cfg_values():
	_music.fill_data(musicBusIndex)
	_sounds.fill_data(soundsBusIndex)
	
	for child in _VBox.get_children():
		child.load_cfg_values()
