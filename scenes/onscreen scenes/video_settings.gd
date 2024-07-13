extends Control

@onready var _videoVBox = $Margin/VBox
@onready var _modeMenu: MenuButton = _videoVBox.get_node("Display Mode/Menu")
@onready var _antialiasingMenu: MenuButton = _videoVBox.get_node("Antialiasing/Menu")
@onready var _VSyncMenu: MenuButton = _videoVBox.get_node("VSync/Menu")
@onready var _fpsLimit: TextEdit = _videoVBox.get_node("FPS Limit/TextEdit")
var prevFpsLimit: int

func _ready():
	load_cfg_values()
	_modeMenu.get_popup().id_pressed.connect(_on_display_mode_chosen)
	_antialiasingMenu.get_popup().id_pressed.connect(_on_antialiasing_chosen)
	_VSyncMenu.get_popup().id_pressed.connect(_on_vsync_mode_chosen)

func load_cfg_values():
	var cfg = Tools.config
	_on_display_mode_chosen(cfg.get_value("video", "display_mode", 0))
	_on_antialiasing_chosen(cfg.get_value("video", "antialiasing", 0))
	_on_vsync_mode_chosen(cfg.get_value("video", "vsync", 0))
	set_fps_limit()

func set_fps_limit():
	prevFpsLimit = Tools.config.get_value("video", "fps_limit", 0)
	_fpsLimit.text = str(prevFpsLimit)
	_on_fps_limit_focus_exited()

func _on_display_mode_chosen(id):
	$/root.mode = id * 2
	$/root.borderless = ($/root.mode == Window.MODE_MAXIMIZED)
	_modeMenu.text = _modeMenu.get_popup().get_item_text(id)
	Tools.config.set_value("video", "display_mode", id)

func _on_antialiasing_chosen(id):
	$/root.msaa_2d = id
	_antialiasingMenu.text = _antialiasingMenu.get_popup().get_item_text(id)
	Tools.config.set_value("video", "antialiasing", id)

func _on_vsync_mode_chosen(id):
	DisplayServer.window_set_vsync_mode(id)
	_VSyncMenu.text = _VSyncMenu.get_popup().get_item_text(id)
	Tools.config.set_value("video", "vsync", id)

func _on_fps_limit_focus_exited():
	if _fpsLimit.text.is_valid_int():
		var num = int(_fpsLimit.text)
		if num >= 0 and num <= 9999:
			Engine.max_fps = num
			Tools.config.set_value("video", "fps_limit", num)
			return

	_fpsLimit.text = str(prevFpsLimit)
