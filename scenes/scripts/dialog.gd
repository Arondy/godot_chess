extends Control

class_name Dialog

func _ready():
	get_tree().paused = true
	#LaterTODO: убрать когда перейдем на fhd
	position = get_window().content_scale_size / 2

func get_text_node() -> RichTextLabel:
	return $Panel/VBox/Text

func get_left_button() -> Button:
	return $Panel/VBox/HBox/ButtonLeft

func get_right_button() -> Button:
	return $Panel/VBox/HBox/ButtonRight
