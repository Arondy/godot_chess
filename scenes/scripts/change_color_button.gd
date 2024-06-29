extends Button

func _ready():
	if not multiplayer.is_server():
		add_theme_stylebox_override("disabled", get_theme_stylebox("pressed"))
		button_pressed = true
	else:
		add_theme_stylebox_override("disabled", get_theme_stylebox("normal").duplicate())
	get_theme_stylebox("disabled").modulate_color = Color(1, 1, 1, 0.6)

func _on_pressed():
	change_color.rpc()

@rpc("authority", "reliable")
func change_color():
	button_pressed = not button_pressed
	var style = "pressed" if button_pressed else "normal"
	add_theme_stylebox_override("disabled", get_theme_stylebox(style))
	get_theme_stylebox("disabled").modulate_color = Color(1, 1, 1, 0.6)
