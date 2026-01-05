# Changelog

## 0.1.4

- Updated to `custom_lint ^0.8.1` and `analyzer ^8.4.0`
- Added explicit `analyzer_plugin ^0.13.10` dependency for stability
- Fixed annotation detection for both const variable and constructor forms
- Improved Future type detection for async function handling

## 0.1.3

- Fixed API compatibility issues with analyzer 8.x element model
- Corrected `PropertyAccessorElement.variable` and `ConstructorElement.enclosingElement` usage
- Fixed `InterfaceType.element` access for Future type checking

## 0.1.2

- Migrated to `custom_lint` package for better IDE integration
- Fixed compatibility with analyzer 8.x
- Improved error messages and correction hints
- Added CLI support via `dart run custom_lint`

## 0.1.0

- Initial release
- `@mustBeHandled` annotation for marking functions requiring error handling
- Support for sync functions (requires try/catch)
- Support for async functions (requires await + try/catch)
- Three distinct lint codes for different violation types
