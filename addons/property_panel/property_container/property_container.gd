class_name PropertyContainer
extends HBoxContainer

## An item in a [PropertyPanel].
##
## Contains a [member name_label] and the [member property_control] the
## [member property] returns. Emits the [signal property_changed] signal when
## the [member property_control] emitted the signal the [member property]
## specified.

signal property_changed(value: Variant)

const _Property = preload("../properties.gd").Property

var property: _Property
var property_control : Control

@onready var name_label : Label = $Name

func setup(_property) -> Control:
	property = _property
	name_label.text = property.name.capitalize()
	property_control = property.get_control()
	property_control.size_flags_horizontal = SIZE_EXPAND_FILL
	property_control.size_flags_vertical = SIZE_EXPAND_FILL
	property_control.custom_minimum_size.x = 60
	property_control.set_drag_forwarding(func(_pos): pass, _can_drop_data_fw, _drop_data_fw)
	var arg_count := 0
	for signal_info in property_control.get_signal_list():
		if signal_info.name == property.changed_signal:
			arg_count = (signal_info.get("args") as Array).size()
			break
	var args := []
	@warning_ignore("return_value_discarded")
	args.resize(4 - arg_count)
	@warning_ignore("return_value_discarded")
	property_control.connect(property.changed_signal,
			_on_PropertyControl_changed.bindv(args))
	add_child(property_control)
	return property_control


func get_value():
	return property._get_value(property_control)


func set_value(to) -> void:
	property._set_value(property_control, to)


func _on_PropertyControl_changed(_a, _b, _c, _d):
	property_changed.emit(get_value())


func _can_drop_data_fw(_position : Vector2, data, _control : Control) -> bool:
	return property._can_drop_data(property_control, data)


func _drop_data_fw(_position : Vector2, data, _control : Control) -> void:
	property._drop_data(property_control, data)
	property_changed.emit(get_value())
