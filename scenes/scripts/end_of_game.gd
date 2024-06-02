extends Control

func _ready():
	position = get_window().size / 2
	$"Stopping rect".size = get_window().size
	$"Stopping rect".anchors_preset = Control.PRESET_CENTER
	$ReferenceRect.size = get_window().size / 3
	$ReferenceRect.anchors_preset = Control.PRESET_CENTER
