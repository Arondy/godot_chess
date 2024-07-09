extends Control

func exit():
	Tools.config.save(Tools.cfgFilePath)
	hide()
	$"/root/Starting menu".visible = true

func _on_exit_pressed():
	exit()

func _unhandled_key_input(event):
	if event is InputEventKey and Input.is_key_pressed(KEY_ESCAPE):
		exit()
