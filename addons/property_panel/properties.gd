## Properties used to edit values in a [PropertyPanel].
##
## Each property can create a [Control] and specifies the signal it emits when it
## changed. It also specifies which member of the control is the resulting value.
## 
## [br][br][b]Creating a Custom Property[/b]
## [codeblock]
## const Property = preload("res://addons/property_panel/properties.gd").Property
## class VectorProperty extends Property:
##   func _init(_name : String, _default := Vector2()) -> void:
##     super("changed", "value", _name, _default)
##
##   func _get_control() -> Control:
##     return VectorEdit.new()
## [/codeblock][br]
## [code]vector_edit.gd[/code]:
## [codeblock]
## extends Control
## signal changed
## 
## var value = Vector2.ZERO
## 
## func _gui_input(event):
##   value = Vector2(1, 1)
##   changed.emit()
## [/codeblock][br]
## Usage:
## [codeblock]
## property_panel.set_properties([
##   VectorProperty.new("motion")
## ])
## [/codeblock]

const _PathPickerButton = preload("res://addons/property_panel/path_picker_button/path_picker_button.gd")

enum SPIN_MODE { BOX, SLIDER }

class Property:
	## Property base class.
	
	var name : String
	var changed_signal : String
	var property_variable : String
	var default
	
	func _init(_changed_signal : String, _property_variable : String,
			_name : String, _default : Variant) -> void:
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
	var choices : Array[String]
	
	func _init(_name : String, _choices : Array[String], _default = null) -> void:
		@warning_ignore("return_value_discarded")
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
	func _init(_name : String, _default := "") -> void:
		@warning_ignore("return_value_discarded")
		super("text_changed", "text", _name, _default)
	
	func _get_control() -> Control:
		return LineEdit.new()


class BoolProperty extends Property:
	func _init(_name : String, _default := false) -> void:
		@warning_ignore("return_value_discarded")
		super("toggled", "button_pressed", _name, _default)
	
	func _get_control() -> Control:
		return CheckBox.new()


class SpinProperty extends Property:
	var mode : SPIN_MODE
	var from : float
	var to : float
	var step : float

	const FloatSlider = preload("float_slider/float_slider.gd")

	func _init(_name, _default, _step):
		@warning_ignore("return_value_discarded")
		super("changed", "value", _name, _default)
		step = _step

	func _get_control() -> Control:
		var spin
		match mode:
			SPIN_MODE.BOX:
				spin = SpinBox.new()
			SPIN_MODE.SLIDER:
				spin = preload(
						"float_slider/float_slider.tscn").instantiate() as FloatSlider
		spin.min_value = from
		spin.max_value = to
		spin.step = step
		return spin


class IntProperty extends SpinProperty:
	func _init(_name,_from=0,_to=100,_default = _from,_step = 1, _mode = SPIN_MODE.SLIDER):
		print(_mode)
		@warning_ignore("return_value_discarded")
		super(_name, _default, _step)
		from = _from
		to = _to
		mode = _mode


class FloatProperty extends SpinProperty:
	func _init(_name,_from=0.0,_to=1.0,_default = _from,_step = 0.01, _mode = SPIN_MODE.SLIDER):
		@warning_ignore("return_value_discarded")
		super(_name, _default, _step)
		from = _from
		to = _to
		mode = _mode


class ColorProperty extends Property:
	func _init(_name : String, _default := Color.WHITE) -> void:
		@warning_ignore("return_value_discarded")
		super("color_changed", "color", _name, _default)
	
	func _get_control() -> Control:
		return ColorPickerButton.new()


class FilePathProperty extends Property:
	var options: Dictionary

	func _init(_name : String, _default := "", _options := {}) -> void:
		@warning_ignore("return_value_discarded")
		super("changed", "path", _name, _default)
		options = _options

	func _get_control() -> Control:
		var button : _PathPickerButton = preload(
				"path_picker_button/path_picker_button.tscn").instantiate()
		button.options = options
		return button
