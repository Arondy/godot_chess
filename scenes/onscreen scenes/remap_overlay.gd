extends Control

@onready var _actionKey: Button = $"../Button"

func _input(event):
	if (_actionKey.button_pressed and Input.is_anything_pressed()
	and ((event is InputEventKey and event.keycode != KEY_ESCAPE)
	or event is InputEventMouseButton)):
		InputMap.action_erase_events("left_mouse")
		InputMap.action_add_event("left_mouse", event)
		_actionKey.text = event.as_text()
		_actionKey.button_pressed = false
		hide()
		Tools.config.set_value("controls", "action", _actionKey.text)
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.keycode == KEY_ESCAPE:
		_actionKey.button_pressed = false
		_actionKey.text = InputMap.action_get_events("left_mouse")[0].as_text()
