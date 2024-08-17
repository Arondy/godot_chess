extends Control

func _input(event):
	if event is InputEventKey and event.is_pressed():
		var allowed_keys = [
			KEY_BACKSPACE, KEY_ESCAPE, KEY_ENTER, KEY_TAB,
			KEY_RIGHT, KEY_LEFT, KEY_UP, KEY_DOWN
		]
		var focused = get_viewport().gui_get_focus_owner()
		var key = event.keycode
		
		if not (focused and focused is TextEdit):
			return

		if key >= KEY_0 and key <= KEY_9:
			var text = focused.text
			if (text.length() >= 2 and
					((text == "10" and key != KEY_0) or text != "10")):
				focused.text = "100"
				focused.set_caret_column(3)
				get_viewport().set_input_as_handled()
		elif key in allowed_keys:
			if key == KEY_ENTER:
				get_viewport().gui_release_focus()
			elif key == KEY_TAB:
				if str(focused.focus_next) != "":
					focused.get_node(focused.focus_next).grab_focus()
				get_viewport().set_input_as_handled()
		else:
			get_viewport().set_input_as_handled()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		Tools.config.save(Tools.cfgFilePath)

func _on_exit_pressed():
	Tools.config.save(Tools.cfgFilePath)
	Tools.inputMapConfig.saveIM()
	hide()
	if $"/root".get_node_or_null("Starting menu"):
		$"/root/Starting menu".visible = true

func _shortcut_input(event):
	if event is InputEventKey and Input.is_key_pressed(KEY_ESCAPE):
		if visible:
			_on_exit_pressed()
		else:
			show()
