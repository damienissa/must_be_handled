# Changelog

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
