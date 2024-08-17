extends Control

@onready var _background: Sprite2D = $Background

var multiplayerScene = preload("res://scenes/onscreen scenes/multiplayer.tscn")
var musicBusIndex = AudioServer.get_bus_index("Music")
var soundsBusIndex = AudioServer.get_bus_index("Sounds")

func _ready():
	var bScale = float(get_window().content_scale_size.x) / _background.texture.get_width()
	_background.scale = Vector2(bScale, bScale)
	load_cfg()
	add_sound_node()

func load_cfg():
	if FileAccess.file_exists(Tools.cfgFilePath):
		Tools.config.load(Tools.cfgFilePath)
		add_settings_node()

func add_sound_node():
	var soundScene = load("res://scenes/sound.tscn")
	var sound = soundScene.instantiate()
	$/root.add_child.call_deferred(sound)
	Tools.sound = sound

func add_settings_node():
	var settingsScene = load("res://scenes/onscreen scenes/settings_menu.tscn")
	var settings = settingsScene.instantiate()
	settings.hide()
	$/root.add_child.call_deferred(settings)

func _on_find_game_pressed():
	get_tree().change_scene_to_packed(multiplayerScene)

func _on_settings_pressed():
	hide()
	$"/root/Settings menu".visible = true

func _on_exit_pressed():
	get_tree().quit()

func _shortcut_input(_event):
	if Input.is_action_just_pressed("find_game"):
		_on_find_game_pressed()
	elif Input.is_action_just_pressed("open_settings"):
		_on_settings_pressed()
