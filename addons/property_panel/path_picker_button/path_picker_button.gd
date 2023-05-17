extends Button

## A [Button] to select a path to be used in a [PropertyPanel].
##
## Right-clicking clears the path.

## Emitted when the path changed.
signal changed

## The current path that is set.
var path : String:
	set(to):
		path = to
		text = path.get_file()
		tooltip_text = path
		@warning_ignore("return_value_discarded")
		emit_signal("changed")
## See [member FileDialog.filters].
var options : Dictionary

func _gui_input(event : InputEvent) -> void:
	var button_ev = event as InputEventMouseButton
	if button_ev and button_ev.pressed and button_ev.button_index == MOUSE_BUTTON_RIGHT:
		path = ""
