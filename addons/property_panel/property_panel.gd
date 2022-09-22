extends Panel
class_name PropertyPanel

## An inspector-like panel that builds a list of `PropertyContainer`s.
## 
## When the `properties` are set, a `PropertyContainer` is generated for each
## property.
## The resulting values can be retrieved using `get_value` and `get_values`.
## A `Dictionary` similar to the result of `get_values` can be given to
## [code]load_values[/code] to update the values of the `PropertyContainers`s.
## 
## [b]Usage[/b]:
##
## [codeblock]
## const Properties = preload("res://addons/property_panel/properties.gd")
## 
## property_panel.set_properties([
## 	Properties.BoolProperty.new("Active"),
## 	Properties.FloatProperty.new("Size", 1, 5),
## 	Properties.EnumProperty.new("Distance", ["Far", "Near"]),
## ])
## [/codeblock]

enum Orientation {
	VERTICAL,
	HORIZONTAL,
}

signal property_changed(property, value)

## Whether the properties should be alligned from left to right or from top to
## bottom.
@export var orientation : Orientation = Orientation.VERTICAL

const PropertyContainer := preload("property_container/property_container.gd")
const Properties := preload("properties.gd")

var _property_container_scene := preload("property_container/property_container.tscn")
# Each editable member's `PropertyContainer`.
var _property_containers : Dictionary

@onready var _file_dialog = %FileDialog
@onready var _properties_container : Container
@onready var _scroll_container : ScrollContainer = $ScrollContainer

func _ready():
	_properties_container = HBoxContainer.new() if\
			orientation == Orientation.HORIZONTAL else VBoxContainer.new()
	_properties_container.size_flags_horizontal = SIZE_EXPAND_FILL
	_properties_container.size_flags_vertical = SIZE_EXPAND_FILL
	_scroll_container.add_child(_properties_container)


func get_value(property : String):
	return (_property_containers[property] as PropertyContainer).get_value()


func set_value(property : String, value):
	return (_property_containers[property] as PropertyContainer).set_value(value)


# Returns true if the property is exposed.
func has_property(property : String) -> bool:
	return property in _property_containers


# Returns a `Dictionary` with the property names as keys and the values as
# values.
func get_values() -> Dictionary:
	var values := {}
	for property in _property_containers:
		values[property] = _property_containers[property].get_value()
	return values


# Store the property/value pairs in an Object or Dictionary.
func store_values(instance) -> void:
	for property in _property_containers:
		var value = _property_containers[property].get_value()
		if instance is Object:
			instance.set(property, value)
		elif instance is Dictionary:
			instance[property] = value


# Load the property values from an Object/Dictionary.
func load_values(instance) -> void:
	# Prevent property containers changed callback from being emitted.
	set_block_signals(true)
	for container in _properties_container.get_children():
		if not container is Label:
			var value = instance.get(container.property.name)
			if value != null:
				container.set_value(value)
	set_block_signals(false)


# Shows a list of section titles and properties.
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
			var container := _property_container_scene.instantiate()
			container.name = property.name
			container.property_changed.connect(_on_Property_changed.bind(container))
			
			_property_containers[property.name] = container
			_properties_container.add_child(container)
			var control : Control = container.setup(property)
			if property is Properties.FilePathProperty:
				control.dialog_opened.connect(_on_path_picker_button_dialog_opened.bind(control))


func _on_path_picker_button_dialog_opened(control):
	_file_dialog.popup_centered_ratio()
	_file_dialog.set_meta("control", control)



func _on_file_dialog_file_selected(path):
	_file_dialog.get_meta("control").select_path(path)


# Clears the panel, removing every property and section title.
func clear() -> void:
	set_properties([])


func _on_Property_changed(value, container : PropertyContainer):
	emit_signal("property_changed", container.property.name, value)

