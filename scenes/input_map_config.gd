extends Resource

class_name InputMapConfig

@export var inputMap: Dictionary

func saveIM():
	for action in InputMap.get_actions().filter(
			func(string: StringName): return string.begins_with("_")
		):
		inputMap[action] = InputMap.action_get_events(action)
		
	ResourceSaver.save(self, Tools.inputMapCfgFilePath)

func loadIM():
	for action in inputMap:
		InputMap.action_erase_events(action)
		for inputEvent in inputMap.get(action):
			InputMap.action_add_event(action, inputEvent)
