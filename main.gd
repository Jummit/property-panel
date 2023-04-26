extends Control

const Properties = preload("res://addons/property_panel/properties.gd")

@onready var middle_property_panel : PropertyPanel = $MiddlePropertyPanel
@onready var top_property_panel : PropertyPanel = $TopPropertyPanel
@onready var editable_texture : TextureRect = $EditableTexture

func _ready() -> void:
	top_property_panel.set_properties([
		Properties.BoolProperty.new("Active"),
		Properties.FilePathProperty.new("Image"),
		Properties.FloatProperty.new("Size", 1, 5),
		Properties.EnumProperty.new("Distance", ["Far", "Near"]),
	])
	middle_property_panel.set_properties([
		Properties.StringProperty.new("name", editable_texture.name),
		Properties.BoolProperty.new("visible", true),
		Properties.FloatProperty.new("rotation_degrees", 1, 360),
		Properties.FloatProperty.new("rotation_degrees", 1, 360),
		Properties.FloatProperty.new("rotation_degrees", 1, 360),
		Properties.ColorProperty.new("modulate"),
		Properties.BoolProperty.new("flip_h"),
	])


func _on_MiddlePropertyPanel_property_changed(property: String,
		value: Variant) -> void:
	editable_texture[property] = value
