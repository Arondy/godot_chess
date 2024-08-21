extends Control

@onready var _controlsVBox: VBoxContainer = $Margin/VBox

func _ready():
	load_cfg_values()
	load_input_map()

func load_cfg_values():
	for child in _controlsVBox.get_children():
		child.load_cfg_values()

func load_input_map():
	if FileAccess.file_exists(Tools.inputMapCfgFilePath):
		Tools.inputMapConfig = load(Tools.inputMapCfgFilePath)
		
		if Tools.inputMapConfig:
			Tools.inputMapConfig.loadIM()
			return
			
	Tools.inputMapConfig = InputMapConfig.new()
