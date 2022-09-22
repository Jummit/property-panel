## Properties used to edit values in a [PropertyPanel].

## Each property can create a `Control` and specifies the signal it emits when it
## changed. It also specifies which member of the control is the resulting value.

class Property:
	var name : String
	var changed_signal : String
	var property_variable : String
	var default
	
	func _init(_changed_signal : String,_property_variable : String,_name : String,_default):
		changed_signal = _changed_signal
		property_variable = _property_variable
		name = _name
		default = _default
	
	func get_control() -> Control:
		var control := _get_control()
		_set_value(control, default)
		return control
	
	func _get_control() -> Control:
		return Control.new()
	
	func _get_value(control : Control):
		return control.get(property_variable)
	
	func _set_value(control : Control, to) -> void:
		control.set(property_variable, to)
	
	func _can_drop_data(control : Control, data) -> bool:
		return typeof(data) == typeof(_get_value(control))
	
	func _drop_data(control : Control, data) -> void:
		_set_value(control, data)


class EnumProperty extends Property:
	var choices : PackedStringArray
	
	func _init(_name,_choices,_default = null):
		super("item_selected", "", _name, _default)
		choices = _choices
		default = _default
		if _default == null:
			default = choices[0]
	
	func _get_control() -> Control:
		var option_button := OptionButton.new()
		for choice in choices:
			option_button.get_popup().add_item(choice)
		option_button.selected = 0
		return option_button
	
	func _get_value(control : Control):
		var option := control as OptionButton
		return choices[option.selected]
	
	func _set_value(control : Control, to) -> void:
		var option := control as OptionButton
		option.selected = (choices as Array).find(to)


class StringProperty extends Property:
	func _init(_name : String,_default := ""):
		super("text_changed", "text", _name, _default)
	
	func _get_control() -> Control:
		return LineEdit.new()


class BoolProperty extends Property:
	func _init(_name,_default := false):
		super("toggled", "button_pressed", _name, _default)
	
	func _get_control() -> Control:
		return CheckBox.new()


class RangeProperty extends Property:
	var from : float
	var to : float
	var step : float
	
	const FloatSlider = preload("float_slider/float_slider.gd")
	
	func _init(_name,_default,_step):
		super("changed", "value", _name, _default)
		_step = step
	
	func _get_control() -> Control:
		var slider : FloatSlider = preload(
				"float_slider/float_slider.tscn").instantiate()
		slider.min_value = from
		slider.max_value = to
		slider.step = step
		return slider


class IntProperty extends RangeProperty:
	func _init(_name,_from,_to,_default = _from):
		super(_name, 1, _default)
		from = _from
		to = _to


class FloatProperty extends RangeProperty:
	func _init(_name,_from=0.0,_to=1.0,_default = _from):
		super(_name, 0.01, _default)
		from = _from
		to = _to


class ColorProperty extends Property:
	func _init(_name,_default := Color.WHITE):
		super("color_changed", "color", _name, _default)
	
	func _get_control() -> Control:
		return ColorPickerButton.new()


class FilePathProperty extends Property:
	func _init(_name : String,_default := ""):
		super("changed", "path", _name, _default)
		pass
	
	func _get_control() -> Control:
		return preload("path_picker_button/path_picker_button.tscn").instantiate()\
				as Control
