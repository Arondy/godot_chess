extends HBoxContainer

@export var action: String
@onready var _label: Label = $Label
@onready var _button: Button = $Button
@onready var _remapOverlay: Control = $"Remap overlay"

func _ready():
	_label.text = "%s:" % name

func load_cfg_values():
	_button.text = Tools.config.get_value("controls", action, InputMap.action_get_events(action)[0].as_text())

func _on_button_pressed():
	if _button.button_pressed:
		_button.text = "Click any key..."
		_remapOverlay.visible = true
