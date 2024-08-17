extends Control

@onready var _audioVBox: VBoxContainer = $Margin/VBox
@onready var _musicSlider: HSlider = _audioVBox.get_node("Music/Music slider")
@onready var _musicVolume: TextEdit = _audioVBox.get_node("Music/Music volume")
@onready var _soundsSlider: HSlider = _audioVBox.get_node("Sounds/Sounds slider")
@onready var _soundsVolume: TextEdit = _audioVBox.get_node("Sounds/Sounds volume")
var musicBusIndex: int = AudioServer.get_bus_index("Music")
var soundsBusIndex: int = AudioServer.get_bus_index("Sounds")

func _ready():
	load_cfg_values()

func load_cfg_values():
	_musicSlider.value = Tools.config.get_value("audio", "music", 1)
	_soundsSlider.value = Tools.config.get_value("audio", "sounds", 1)
	
func on_slider_value_changed(value: float, busIndex: int, volumeText: TextEdit):
	AudioServer.set_bus_volume_db(busIndex, linear_to_db(value))
	volumeText.text = str(value * 100)

func _on_slider_drag_ended(value_changed: bool, category: String, slider: HSlider):
	if not value_changed:
		return
		
	Tools.config.set_value("audio", category, slider.value)

func update_sliders_from_text(volumeText: TextEdit, slider: HSlider):
	var string = volumeText.text
	var value = slider.value
	
	if string.is_valid_int():
		var num = float(string) / 100
		
		if num >= 0 and num <= 1:
			var valueChanged = (num != value)
			slider.value = num
			
			if volumeText == _musicVolume:
				_on_music_slider_drag_ended(valueChanged)
			else:
				_on_sounds_slider_drag_ended(valueChanged)
				
			return
			
	volumeText.text = str(value * 100)

func _on_music_slider_drag_ended(value_changed: bool):
	_on_slider_drag_ended(value_changed, "music", _musicSlider)

func _on_music_slider_value_changed(value: float):
	on_slider_value_changed(value, musicBusIndex, _musicVolume)

func _on_music_volume_focus_exited():
	update_sliders_from_text(_musicVolume, _musicSlider)

func _on_sounds_slider_drag_ended(value_changed: bool):
	_on_slider_drag_ended(value_changed, "sounds", _soundsSlider)

func _on_sounds_slider_value_changed(value: float):
	on_slider_value_changed(value, soundsBusIndex, _soundsVolume)

func _on_sounds_volume_focus_exited():
	update_sliders_from_text(_soundsVolume, _soundsSlider)
