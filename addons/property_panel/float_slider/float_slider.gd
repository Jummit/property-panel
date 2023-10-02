extends LineEdit
class_name FloatSlider
## A number slider similar to that found in Godot Engine's inspector.

## Emitted when the user changes the value by sliding or by typing it in.
signal value_changed(value: float)

## The current number.
@export var value : float:
	set(to):
		value = snapped(clamp(snapped(to, step), min_value, max_value), 0.001)
		text = str(value)
## The mininum value allowed by sliding. Smaller numbers can be inputed manually.
@export var min_value : float
## The maximum value allowed.
@export var max_value : float
## The number the value will be snapped to. Useful for integer inputs.
@export var step : float
## The sensitivity while dragging with the mouse to change the value.
@export var sensitivity := 1000.0
## The allow expressions to evaluate to get the value.
@export var allow_expressions := true

@onready var _knob: Control = %Knob

## Wether the user is dragging the text field.
var _dragging := false
var _dragged_position : Vector2
## Wether the user has grabbed the slider grabber.
var _grabbed := false
var _clicked := false
var _text_editing := false
var _initialy_clicked_position : Vector2
var _expression := Expression.new()

const _NOT_CLICKED = Vector2.ZERO

func _input(event : InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if _dragging:
		_knob.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var button_ev := event as InputEventMouseButton
	var motion_ev := event as InputEventMouseMotion
	if button_ev:
		var in_rect := get_global_rect().grow_side(3, 3).has_point(button_ev.position)
		if button_ev.pressed and _initialy_clicked_position == _NOT_CLICKED:
			_initialy_clicked_position = button_ev.position
		elif not button_ev.pressed:
			_initialy_clicked_position = _NOT_CLICKED
		if not button_ev.pressed:
			if _grabbed:
				_grabbed = false
			elif _dragging:
				_dragging = false
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
#				warp_mouse.call_deferred(_dragged_position)
			elif in_rect and _clicked:
				mouse_filter = Control.MOUSE_FILTER_STOP
				grab_focus()
		_clicked = button_ev.pressed and in_rect
	if motion_ev and motion_ev.button_mask == MOUSE_BUTTON_LEFT:
		var in_rect := get_global_rect().has_point(motion_ev.position)
		if _grabbed:
			value = remap(motion_ev.position.x,
					global_position.x,
					global_position.x + size.x, min_value, max_value)
			@warning_ignore("return_value_discarded")
			value_changed.emit(value)
		elif _dragging:
			# Disabled to support more input methods, mainly graphic tablets
			# in absolute mode.
#			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			release_focus()
			value += motion_ev.relative.x * ((max_value - min_value)
					/ sensitivity) * _get_change_modifier()
			@warning_ignore("return_value_discarded")
			value_changed.emit(value)
		elif _mouse_near_grabber() and _clicked and not _text_editing:
			_grabbed = true
		elif in_rect and _clicked and _initialy_clicked_position.distance_to(motion_ev.position) > 4:
			_dragged_position = motion_ev.position - global_position
			_dragging = true
	queue_redraw()
	_knob.queue_redraw()


func _gui_input(event : InputEvent) -> void:
	if event.is_action("ui_cancel"):
		release_focus()
		mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	draw_rect(Rect2(Vector2(0, size.y - 2), Vector2(size.x, 2)),
			Color.DIM_GRAY)
	var grabber_size := Vector2(4, 2)
	draw_rect(Rect2(_get_grabber_pos() - Vector2.RIGHT * 2, grabber_size),
			Color.WHITE)


func _on_focus_entered() -> void:
	_text_editing = true


func _on_focus_exited():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_text_editing = false
	text = str(value)


func _on_text_changed(new_text : String) -> void:
	if new_text.is_valid_float():
		var last_carret := caret_column
		value = new_text.to_float()
		# Avoid emitting [method _on_text_changed].
		set_block_signals(true)
		text = new_text
		set_block_signals(false)
		caret_column = last_carret
		@warning_ignore("return_value_discarded")
		emit_signal("value_changed", value)


func _on_text_entered(new_text : String) -> void:
	if allow_expressions:
		var error = _expression.parse(new_text)
		if error != OK:
			push_error(_expression.get_error_text())
		elif not _expression.has_execute_failed():
			value = float(_expression.execute())
	else:
		value = new_text.to_float()
	release_focus()
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _get_change_modifier() -> float:
	return .2 if Input.is_key_pressed(KEY_SHIFT) else 1.0


func _get_grabber_pos() -> Vector2:
	return Vector2(remap(value, min_value, max_value, 0, size.x), size.y - 2)


func _mouse_near_grabber() -> bool:
	return get_local_mouse_position().distance_to(_get_grabber_pos()) < 10


func _on_knob_draw() -> void:
	if not _text_editing and (_dragging or _grabbed or Rect2(Vector2.ZERO,
			size + Vector2.DOWN * 10).has_point(get_local_mouse_position())):
		var texture := preload("grabber.svg")
		if _mouse_near_grabber() or _grabbed:
			texture = preload("selected_grabber.svg")
		_knob.draw_texture(texture,
				global_position + _get_grabber_pos() - texture.get_size() / 2)
