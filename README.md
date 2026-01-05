# must_be_handled

A Dart analyzer plugin that enforces **explicit error-handling contracts** at compile time by introducing a `@mustBeHandled` annotation.

Functions or methods annotated with `@mustBeHandled` **must be explicitly handled by the caller**, otherwise the analyzer reports an error.

This brings **checked-exception–like discipline** to Dart without changing the language.

## Features

- 🎯 **Compile-time enforcement** — Errors appear in your IDE and during analysis
- 🔄 **Sync and async support** — Handles both synchronous and asynchronous functions
- ⏳ **Await verification** — Ensures async functions are properly awaited
- 🛡️ **try/catch validation** — Verifies calls are wrapped in try/catch blocks
- 📍 **Precise diagnostics** — Clear error messages with correction hints

## Getting Started

### 1. Add the dependency

```yaml
dependencies:
  must_be_handled: ^0.1.0
```

### 2. Enable the plugin

Add to your `analysis_options.yaml`:

```yaml
plugins:
  - must_be_handled
```

### 3. Annotate your functions

```dart
import 'package:must_be_handled/must_be_handled.dart';

@mustBeHandled
Future<User> fetchUser() async {
  // This function might throw!
}
```

## Usage

### Sync Functions

Sync functions annotated with `@mustBeHandled` must be wrapped in a `try/catch` block:

```dart
@mustBeHandled
void dangerousSync() {
  throw Exception('Something went wrong!');
}

void main() {
  // ❌ Invalid — not in try/catch
  dangerousSync();

  // ✅ Valid — wrapped in try/catch
  try {
    dangerousSync();
  } catch (e) {
    print('Error: $e');
  }
}
```

### Async Functions

Async functions annotated with `@mustBeHandled` must be **both awaited AND wrapped in try/catch**:

```dart
@mustBeHandled
Future<String> fetchData() async {
  throw Exception('Network error!');
}

void main() async {
  // ❌ Invalid — not awaited
  fetchData();

  // ❌ Invalid — awaited but not in try/catch
  await fetchData();

  // ❌ Invalid — not awaited (false safety)
  try {
    fetchData(); // not awaited!
  } catch (_) {}

  // ✅ Valid — awaited AND in try/catch
  try {
    final data = await fetchData();
    print(data);
  } catch (e) {
    print('Error: $e');
  }
}
```

### Class Methods

The annotation works on class methods too:

```dart
class ApiService {
  @mustBeHandled
  Future<Response> post(String url, Map<String, dynamic> body) async {
    // ...
  }
}

void main() async {
  final api = ApiService();
  
  // ✅ Valid
  try {
    final response = await api.post('/users', {'name': 'John'});
    print(response);
  } catch (e) {
    print('API error: $e');
  }
}
```

### Constructor Annotation

You can use either the constant or the constructor:

```dart
// Using the constant (preferred)
@mustBeHandled
void danger1() {}

// Using the constructor
@MustBeHandled()
void danger2() {}
```

## Enforcement Rules

| Rule | Description |
|------|-------------|
| **Sync functions** | Must be inside `try` block (not `catch`/`finally`) |
| **Async functions** | Must be `await`ed AND inside `try` block |
| **Scope** | Call must be in `try {}` body, not in `catch` or `finally` |

## Explicitly Not Supported (v1)

The following patterns are **not** considered valid handling:

```dart
// ❌ These don't satisfy @mustBeHandled
fetchUser().catchError(...)
runZonedGuarded(...)
fetchUser().then(...).catchError(...)
```

**Rationale:** These patterns are ambiguous and harder to statically verify. Future versions may add opt-in support.

## IDE Support

The plugin works with:

- ✅ VS Code (with Dart extension)
- ✅ IntelliJ IDEA / Android Studio
- ✅ `dart analyze` command

## Example

See the [example](example/) directory for a complete working example.

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

BSD-3-Clause — See [LICENSE](LICENSE) for details.
