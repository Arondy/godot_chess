extends Control

@onready var _scroll: ScrollContainer = $Panel/VBox/Scroll
@onready var _chat_VBox: VBoxContainer = _scroll.get_node("VBox")

@rpc("any_peer", "call_local", "reliable")
func add_message(nickname: String, message: String):
	var label = Label.new()
	label.text = "%s: %s" % [nickname, message]
	_chat_VBox.add_child(label)
	var scrollBar = _scroll.get_v_scroll_bar()
	await scrollBar.changed
	_scroll.scroll_vertical = scrollBar.max_value
