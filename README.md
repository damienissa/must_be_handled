# must_be_handled

A Dart analyzer plugin that enforces explicit error-handling contracts at compile time using the `@mustBeHandled` annotation.

Built with [custom_lint](https://pub.dev/packages/custom_lint) for seamless IDE integration.

## Features

- 🔒 **Compile-time safety** - Catches unhandled errors before runtime
- ⚡ **Async-aware** - Distinguishes between sync and async functions
- 🎯 **Precise diagnostics** - Clear error messages with correction hints
- 🔄 **IDE integration** - Real-time feedback in your editor
- 🧪 **CLI support** - Run checks in CI/CD pipelines

## Installation

Add to your `pubspec.yaml`:

```yaml
dev_dependencies:
  custom_lint: ^0.8.1
  must_be_handled: ^0.1.1
```

Enable the plugin in your `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - custom_lint
```

Run `dart pub get` (or `flutter pub get` for Flutter projects).

## Usage

### Annotating Functions

Import the package and annotate functions that require explicit error handling:

```dart
import 'package:must_be_handled/must_be_handled.dart';

// Using the const annotation
@mustBeHandled
void dangerousSync() {
  throw Exception('Something went wrong!');
}

// Using the constructor annotation
@MustBeHandled()
Future<User> fetchUser() async {
  // Network request that might fail...
}
```

### Handling Calls

The plugin enforces these rules:

#### Sync Functions
Must be wrapped in `try/catch`:

```dart
// ✅ Valid
try {
  dangerousSync();
} catch (e) {
  handleError(e);
}

// ❌ Invalid - will show warning
dangerousSync(); // must_be_handled_sync
```

#### Async Functions
Must be **both** `await`ed **and** wrapped in `try/catch`:

```dart
// ✅ Valid
try {
  await fetchUser();
} catch (e) {
  handleError(e);
}

// ❌ Invalid - not awaited
fetchUser(); // must_be_handled_async_not_awaited

// ❌ Invalid - awaited but not in try/catch
await fetchUser(); // must_be_handled_async_not_handled

// ❌ Invalid - in try/catch but not awaited (false safety!)
try {
  fetchUser(); // must_be_handled_async_not_awaited
} catch (_) {}
```

## Lint Codes

| Code | Description |
|------|-------------|
| `must_be_handled_sync` | Sync function not wrapped in try/catch |
| `must_be_handled_async_not_awaited` | Async function not awaited |
| `must_be_handled_async_not_handled` | Async function awaited but not in try/catch |

## Running in CI

Use the custom_lint CLI to check for violations:

```bash
# Dart projects
dart run custom_lint

# Flutter projects  
flutter pub run custom_lint
```

The command exits with code 1 if any issues are found.

## Configuration

You can disable specific rules in your `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - custom_lint

custom_lint:
  rules:
    - must_be_handled_sync: false  # disable sync check
```

## Not Supported

The following patterns are **not** detected (by design):

- `.catchError()` - The plugin requires `try/catch` blocks
- `.then()` chains - Use `await` instead
- Variables holding Futures - Only direct calls are analyzed
- Nested function calls - Only the outermost call is checked

## IDE Support

The plugin works with any IDE that supports the Dart Analysis Server:

- **VS Code** - Install the Dart/Flutter extension
- **Android Studio / IntelliJ** - Built-in support
- **Other IDEs** - May require LSP configuration

After installation, restart your IDE or run "Dart: Restart Analysis Server".

## Example

See the [example](example/) directory for a complete demonstration.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

BSD-3-Clause - See [LICENSE](LICENSE) for details.
