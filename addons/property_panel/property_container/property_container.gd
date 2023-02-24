class_name PropertyContainer
extends HBoxContainer

## An item in a `PropertyPanel`

## Contains a `name_label` and the `property_control` the `property` returns.
## Emits the `property_changed` signal when the `property_control` emitted the
## `changed_signal` the `property` specified.

signal property_changed(value)

const Property = preload("../properties.gd").Property

var property: Property
var property_control : Control

@onready var name_label : Label = $Name

func setup(_property) -> Control:
	property = _property
	name_label.text = property.name.capitalize()
	property_control = property.get_control()
	property_control.size_flags_horizontal = SIZE_EXPAND_FILL
	property_control.size_flags_vertical = SIZE_EXPAND_FILL
	property_control.custom_minimum_size.x = 60
	property_control.set_drag_forwarding(func(): pass, _can_drop_data_fw, _drop_data_fw)
	# This is a little hacky; since the argument count of signal callbacks have.
	var args = 0
	for signal_info in property_control.get_signal_list():
		if signal_info.name == property.changed_signal:
			args = 2 - (signal_info.args as Array).size()
			break
	if args == 0:
		property_control.connect(property.changed_signal, _on_PropertyControl_changed)
	elif args == 1:
		property_control.connect(property.changed_signal, _on_PropertyControl_changed.bind(1))
	elif args == 2:
		property_control.connect(property.changed_signal, _on_PropertyControl_changed.bind(1, 1))
	add_child(property_control)
	return property_control


func get_value():
	return property._get_value(property_control)


func set_value(to) -> void:
	property._set_value(property_control, to)


func _on_PropertyControl_changed(_a, _b):
	emit_signal("property_changed", get_value())


func _can_drop_data_fw(_position : Vector2, data, _control : Control) -> bool:
	return property._can_drop_data(property_control, data)


func _drop_data_fw(_position : Vector2, data, _control : Control) -> void:
	property._drop_data(property_control, data)
	emit_signal("property_changed", get_value())
