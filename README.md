# Property Panel Addon ![Godot v4.0.2](https://img.shields.io/badge/Godot-v4.0.2-%23478cbf) ![GitHub](https://img.shields.io/github/license/Jummit/property-panel)

A panel similar to the Inspector inside the Godot Engine. Can be used to expose various values inside tools / games.

**Supports:**

* Strings
* Boolean values
* Floating point or integer values
* Colors
* Enums
* Exposing file paths which open a file dialog when clicking them
* Custom properties (see `properties.gd` for a tutorial)

**Screenshot:**

![screenshot](screenshots/screenshot.png)

**Example Code:**

In this example a sprite's values are exposed in a property panel.

```gdscript
const Properties = preload("res://addons/property_panel/properties.gd")

func _ready():
	$PropertyPanel.set_properties([
		Properties.StringProperty.new("name", "A Texture"),
		Properties.BoolProperty.new("visible", true),
		Properties.FloatProperty.new("rotation_degrees", 1, 360),
		Properties.ColorProperty.new("modulate"),
		Properties.BoolProperty.new("flip_h"),
	])

func _on_PropertyPanel_property_changed(property, value):
	$Sprite[property] = value
```
