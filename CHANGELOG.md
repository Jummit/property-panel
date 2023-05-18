# Changelog

## Version 3.0

### Breaking Changes

- `FilePathProperty` now takes a dictionary of properties instead of a filter array.

### Fixes

- Custom minimum size of the property panel will now be kept if it's big enough.
- Fix property constructors not setting values

### Added

- Allow configuring step of `FloatProperty`.
- Default values for number property constructors.

## Version 2.0

### Breaking Changes

- Remove `property_panel.tscn`. To migrate, first select the instantiated scenes, right click and select `Make Local`. Then remove the internally used nodes.

### Added

- Add usage section to the readme.

## Version 1.0

Initial release.
