extends Button

## A [Button] to select a path to be used in a [PropertyPanel].
##
## Right-clicking clears the path.

signal changed
signal dialog_opened

var path : String:
	set(to):
		path = to
		text = path.get_file()
		tooltip_text = path
var filters : PackedStringArray

func _gui_input(event : InputEvent) -> void:
	var button_ev = event as InputEventMouseButton
	if button_ev and button_ev.pressed and button_ev.button_index == MOUSE_BUTTON_RIGHT:
			path = ""
			@warning_ignore("return_value_discarded")
			emit_signal("changed")


func select_path(selected_path : String) -> void:
	path = selected_path
	@warning_ignore("return_value_discarded")
	emit_signal("changed")


func _pressed() -> void:
	dialog_opened.emit()
