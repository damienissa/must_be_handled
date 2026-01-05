# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-01-05

### Added

- Initial release
- `@mustBeHandled` annotation for marking functions that require explicit error handling
- `MustBeHandled` class for constructor-style annotation
- Analyzer plugin that enforces:
  - Sync functions must be wrapped in `try/catch`
  - Async functions must be `await`ed
  - Async functions must be wrapped in `try/catch`
- Support for method invocations on objects
- Support for function expression invocations
- Comprehensive test suite
- Example demonstrating usage
