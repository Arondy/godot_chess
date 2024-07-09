extends Control

@onready var _videoVBox = $Margin/VBox
@onready var _modeMenu: MenuButton = _videoVBox.get_node("Display Mode/Menu")
@onready var _antialiasingMenu: MenuButton = _videoVBox.get_node("Antialiasing/Menu")

#TODO: vsync, buttons, sensitivity
func _ready():
	load_cfg_values()
	_modeMenu.get_popup().id_pressed.connect(_on_display_mode_chosen)
	_antialiasingMenu.get_popup().id_pressed.connect(_on_antialiasing_chosen)

func load_cfg_values():
	var cfg = Tools.config
	_on_display_mode_chosen(cfg.get_value("video", "display_mode", 0))
	_on_antialiasing_chosen(cfg.get_value("video", "antialiasing", 0))

func _on_display_mode_chosen(id):
	$/root.mode = id * 2
	$/root.borderless = (id == Window.MODE_MAXIMIZED)
	_modeMenu.text = _modeMenu.get_popup().get_item_text(id)
	Tools.config.set_value("video", "display_mode", id)

func _on_antialiasing_chosen(id):
	$/root.msaa_2d = id
	_antialiasingMenu.text = _antialiasingMenu.get_popup().get_item_text(id)
	Tools.config.set_value("video", "antialiasing", id)
