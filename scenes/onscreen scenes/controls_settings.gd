extends Control

@onready var _controlsVBox = $Margin/VBox
@onready var _actionKey: Button = _controlsVBox.get_node("Action/Button")
@onready var _remapOverlay = _controlsVBox.get_node("Action/Remap overlay")

func _ready():
	load_cfg_values()
	load_input_map()

func load_cfg_values():
	_actionKey.text = Tools.config.get_value("controls", "action", "Left Mouse Button")

func load_input_map():
	if FileAccess.file_exists(Tools.inputMapCfgFilePath):
		Tools.inputMapConfig = load(Tools.inputMapCfgFilePath)
		
		if Tools.inputMapConfig:
			Tools.inputMapConfig.loadIM()
			return
			
	Tools.inputMapConfig = InputMapConfig.new()

func _on_button_pressed():
	if _actionKey.button_pressed:
		_actionKey.text = "Click any key..."
		_remapOverlay.visible = true
