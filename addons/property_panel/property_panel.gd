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

enum Orientation {
	VERTICAL,
	HORIZONTAL,
}

signal property_changed(property, value)

## Whether the properties should be alligned from left to right or from top to
## bottom.
@export var orientation := Orientation.VERTICAL

const Properties := preload("properties.gd")

const PathPickerButton := preload("res://addons/property_panel/path_picker_button/path_picker_button.gd")
var _property_container_scene := preload("property_container/property_container.tscn")
## Each editable member's [PropertyContainer].
var _property_containers : Dictionary
var _currently_choosing_path_for : PathPickerButton

@onready var _file_dialog : FileDialog = %FileDialog
@onready var _properties_container : Container
@onready var _scroll_container : ScrollContainer = $ScrollContainer

func _ready():
	@warning_ignore("incompatible_ternary")
	_properties_container = HBoxContainer.new() if\
			orientation == Orientation.HORIZONTAL else VBoxContainer.new()
	_properties_container.size_flags_horizontal = SIZE_EXPAND_FILL
	_properties_container.size_flags_vertical = SIZE_EXPAND_FILL
	_scroll_container.add_child(_properties_container)


func get_value(property : String):
	return (_property_containers.get(property) as PropertyContainer).get_value()


func set_value(property : String, value):
	(_property_containers.get(property) as PropertyContainer).set_value(value)


## Returns true if the property is exposed.
func has_property(property : String) -> bool:
	return property in _property_containers


## Returns a `Dictionary` with the property names as keys and the values as
## values.
func get_values() -> Dictionary:
	var values := {}
	for property in _property_containers:
		var container := (_property_containers.get(property) as PropertyContainer)
		values[property] = container.get_value()
	return values


## Store the property/value pairs in an [Object] or [Dictionary].
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
			var container : PropertyContainer = _property_container_scene.instantiate()
			container.name = property.name
			var __ := container.property_changed.connect(_on_Property_changed.bind(container))
			
			_property_containers[property.name] = container
			_properties_container.add_child(container)
			var control : Control = container.setup(property)
			var picker_button := control as PathPickerButton
			if picker_button:
				__ = picker_button.dialog_opened.connect(
						_on_path_picker_button_dialog_opened.bind(control))


## Clears the panel, removing every property and section title.
func clear() -> void:
	set_properties([])


func _on_Property_changed(value, container : PropertyContainer):
	property_changed.emit(container.property.name, value)


func _on_path_picker_button_dialog_opened(path_picker: PathPickerButton):
	_file_dialog.popup_centered_ratio()
	_file_dialog.filters = path_picker.filters
	_currently_choosing_path_for = path_picker


func _on_file_dialog_file_selected(path: String):
	_currently_choosing_path_for.select_path(path)


func _on_file_dialog_close_requested() -> void:
	_currently_choosing_path_for = null
