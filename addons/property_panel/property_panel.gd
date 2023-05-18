extends Panel
class_name PropertyPanel

## An inspector-like panel that builds a list of [PropertyContainer]s.
## 
## When the properties are set, a [PropertyContainer] is generated for each
## property.
## The resulting values can be retrieved using [method get_value] and [method get_values].
## A [Dictionary] similar to the result of [method get_values] can be given to
## [code]load_values[/code] to update the values of the [PropertyContainer]s.
## 
## [br][br][b]Usage[/b]:
##
## [codeblock]
## const Properties = preload("res://addons/property_panel/properties.gd")
## 
## property_panel.set_properties([
##   Properties.BoolProperty.new("Active"),
##   Properties.FloatProperty.new("Size", 1, 5),
##   Properties.EnumProperty.new("Distance", ["Far", "Near"])
## ])
## [/codeblock]

signal property_changed(property, value)

## Whether the properties should be alligned from left to right or from top to
## bottom.
@export var vertical := true:
	set(to):
		vertical = to
		if not is_inside_tree():
			await ready
		_properties_container.vertical = vertical

const _Property = preload("properties.gd").Property
const _PathPickerButton = preload("path_picker_button/path_picker_button.gd")

var _property_container_scene := preload("property_container/property_container.tscn")
## Each editable member's [PropertyContainer].
var _property_containers : Dictionary
var _currently_choosing_path_for : _PathPickerButton

var _file_dialog := FileDialog.new()
var _properties_container := BoxContainer.new()


func _ready() -> void:
	_setup_internal_nodes()
	# Avoid scrollbar when the layout is vertical.
	custom_minimum_size.y = min(40, custom_minimum_size.y)


## Returns the current value of a property control.
func get_value(property : String):
	return (_property_containers.get(property) as PropertyContainer).get_value()


## Set the current value of a property control.
func set_value(property : String, value):
	(_property_containers.get(property) as PropertyContainer).set_value(value)


## Returns true if the property is exposed.
func has_property(property : String) -> bool:
	return property in _property_containers


## Returns a [Dictionary] with the property names as keys and the values as
## values.
func get_values() -> Dictionary:
	var values := {}
	for property in _property_containers:
		var container := (_property_containers.get(property) as PropertyContainer)
		values[property] = container.get_value()
	return values


## Store the property/value pairs in an [Object] or [Dictionary].*
func store_values(instance: Variant) -> void:
	assert(instance is Object or instance is Dictionary,
			"Couldn't store values inside variant of type %s, expected Object or Dictionary" % typeof(instance))
	for property in _property_containers:
		var container := (_property_containers.get(property) as PropertyContainer)
		var value : Variant = container.get_value()
		@warning_ignore("unsafe_method_access")
		instance.set(property, value)


## Load the property values from an [Object] or [Dictionary].
func load_values(instance: Variant) -> void:
	# Prevent property containers changed callback from being emitted.
	set_block_signals(true)
	assert(instance is Object or instance is Dictionary,
			"Couldn't load value from variant of type %s, expected Object or Dictionary" % typeof(instance))
	for _container in _properties_container.get_children():
		var container := _container as PropertyContainer
		if container:
			@warning_ignore("unsafe_method_access")
			var value : Variant = instance.get(container.property.name)
			if value != null:
				container.set_value(value)
	set_block_signals(false)


## Shows a list of section titles and properties.
func set_properties(properties : Array) -> void:
	for container in _properties_container.get_children():
		container.queue_free()
	_property_containers.clear()
	
	for property in properties:
		if property is String:
			# A section title.
			var label := Label.new()
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.text = property
			_properties_container.add_child(label)
		else:
			_add_property_containery(property)


func _setup_internal_nodes() -> void:
	# TODO: These should be configurable from path picker buttons as well.
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	@warning_ignore("return_value_discarded")
	_file_dialog.file_selected.connect(_on_file_dialog_file_selected)
	@warning_ignore("return_value_discarded")
	_file_dialog.close_requested.connect(_on_file_dialog_close_requested)
	add_child(_file_dialog)
	var scroll_container := ScrollContainer.new()
	_properties_container.vertical = vertical
	_properties_container.size_flags_horizontal = 3
	scroll_container.add_child(_properties_container)
	scroll_container.clip_contents = false
	scroll_container.anchor_right = 1
	scroll_container.anchor_bottom = 1
	scroll_container.offset_left = 5
	scroll_container.offset_top = 5
	scroll_container.offset_right = -5
	scroll_container.offset_bottom = -5
	scroll_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	scroll_container.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(scroll_container)


func _add_property_containery(property: _Property) -> void:
	var container : PropertyContainer = _property_container_scene.instantiate()
	container.name = property.name
	@warning_ignore("return_value_discarded")
	container.property_changed.connect(_on_Property_changed.bind(container))
	
	_property_containers[property.name] = container
	_properties_container.add_child(container)
	var control : Control = container.setup(property)
	var picker_button := control as _PathPickerButton
	if picker_button:
		@warning_ignore("return_value_discarded")
		picker_button.pressed.connect(
				_on_path_picker_button_dialog_opened.bind(control))


## Clears the panel, removing every property and section title.
func clear() -> void:
	set_properties([])


func _on_Property_changed(value, container : PropertyContainer):
	property_changed.emit(container.property.name, value)


func _on_path_picker_button_dialog_opened(path_picker: _PathPickerButton):
	for key in path_picker.options:
		_file_dialog[key] = path_picker.options[key]
	_file_dialog.popup_centered_ratio(0.4)
	_currently_choosing_path_for = path_picker


func _on_file_dialog_file_selected(path: String):
	_currently_choosing_path_for.path = path


func _on_file_dialog_close_requested() -> void:
	_currently_choosing_path_for = null
