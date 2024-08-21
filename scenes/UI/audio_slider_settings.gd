extends HBoxContainer

var busIndex: int
@export var secondCategory: String
@export var defaultVolume: float = 1
@onready var _label: Label = $Label
@onready var _slider: HSlider = $Slider
@onready var _textValue: TextEdit = $"Text value"

func _ready():
	_label.text = "%s:" % name

func fill_data(newBusIndex: int):
	busIndex = newBusIndex

func load_cfg_values():
	_slider.value = Tools.config.get_value("audio", secondCategory, defaultVolume)

func _on_slider_value_changed(value: float):
	AudioServer.set_bus_volume_db(busIndex, linear_to_db(value))
	_textValue.text = str(value * 100)

func _on_slider_drag_ended(value_changed: bool):
	if not value_changed:
		return
		
	Tools.config.set_value("audio", secondCategory, _slider.value)

func update_sliders_from_text():
	var string = _textValue.text
	var value = _slider.value
	
	if string.is_valid_int():
		var num = float(string) / 100
		
		if num >= 0 and num <= 1:
			var valueChanged = (num != value)
			_slider.value = num
			_on_slider_drag_ended(valueChanged)
			return
			
	_textValue.text = str(value * 100)
