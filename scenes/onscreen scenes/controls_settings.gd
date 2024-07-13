extends Control

@onready var _controlsVBox = $Margin/VBox
@onready var _actionKey: Button = _controlsVBox.get_node("Action/Button")
@onready var _notify = _controlsVBox.get_node("Action/Notification")

func _ready():
	load_cfg_values()

func load_cfg_values():
	_actionKey.text = Tools.config.get_value("controls", "action", "Left Mouse Button")
	
func _on_button_pressed():
	if _actionKey.button_pressed:
		_actionKey.text = "Click any key..."
		_notify.visible = true
	else:
		_actionKey.button_pressed = true

func _unhandled_input(event):
	if (_actionKey.button_pressed and Input.is_anything_pressed()
	and ((event is InputEventKey and event.keycode != KEY_ESCAPE)
	or event is InputEventMouseButton)):
		InputMap.action_erase_events("left_mouse")
		InputMap.action_add_event("left_mouse", event)
		_actionKey.text = event.as_text()
		_actionKey.button_pressed = false
		_notify.visible = false
		Tools.config.set_value("controls", "action", _actionKey.text)
		get_viewport().set_input_as_handled()
