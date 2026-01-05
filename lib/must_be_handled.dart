/// A Dart analyzer plugin that enforces explicit error-handling contracts
/// at compile time using the @mustBeHandled annotation.
///
/// Functions or methods annotated with `@mustBeHandled` must be explicitly
/// handled by the caller, otherwise the analyzer reports an error.
///
/// ## Usage
///
/// Add this package to your `pubspec.yaml`:
///
/// ```yaml
/// dependencies:
///   must_be_handled: ^0.1.0
/// ```
///
/// Then enable the plugin in your `analysis_options.yaml`:
///
/// ```yaml
/// plugins:
///   - must_be_handled
/// ```
///
/// ## Annotating Functions
///
/// ```dart
/// import 'package:must_be_handled/must_be_handled.dart';
///
/// @mustBeHandled
/// Future<User> fetchUser() async {
///   // ...
/// }
/// ```
///
/// ## Handling Calls
///
/// ```dart
/// // ✅ Valid - awaited and in try/catch
/// try {
///   await fetchUser();
/// } catch (_) {
///   // handle error
/// }
///
/// // ❌ Invalid - not in try/catch
/// await fetchUser();
///
/// // ❌ Invalid - not awaited
/// fetchUser();
/// ```
library;

export 'src/annotation.dart';
