extends Control

@onready var _button: Button = $"../Button"
@onready var action: String = $"..".action

func _input(event):
	if (_button.button_pressed and Input.is_anything_pressed()
			and ((event is InputEventKey and event.keycode != KEY_ESCAPE)
			or event is InputEventMouseButton)):
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)
		_button.text = event.as_text()
		_button.button_pressed = false
		hide()
		Tools.config.set_value("controls", action, _button.text)
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.keycode == KEY_ESCAPE:
		_button.button_pressed = false
		_button.text = InputMap.action_get_events(action)[0].as_text()
