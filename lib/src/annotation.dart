/// Annotation that marks a function or method as requiring explicit error handling.
///
/// When a function is annotated with `@mustBeHandled`, any call to that function
/// must be wrapped in a try/catch block. For async functions, the call must also
/// be awaited.
///
/// ## Rules
///
/// ### Sync functions
/// Must be called inside a `try/catch` block:
///
/// ```dart
/// @mustBeHandled
/// void dangerousSync() { ... }
///
/// // ❌ Invalid
/// dangerousSync();
///
/// // ✅ Valid
/// try {
///   dangerousSync();
/// } catch (_) { }
/// ```
///
/// ### Async functions (Future)
/// Must be awaited AND inside a `try/catch` block:
///
/// ```dart
/// @mustBeHandled
/// Future<User> fetchUser() async { ... }
///
/// // ❌ Invalid - not awaited
/// fetchUser();
///
/// // ❌ Invalid - awaited but not caught
/// await fetchUser();
///
/// // ❌ Invalid - not awaited (false safety)
/// try {
///   fetchUser();
/// } catch (_) { }
///
/// // ✅ Valid
/// try {
///   await fetchUser();
/// } catch (_) { }
/// ```
class MustBeHandled {
  /// Creates a new [MustBeHandled] annotation.
  const MustBeHandled();
}

/// Convenience constant for `@mustBeHandled` annotation.
///
/// Use this to annotate functions that must be explicitly handled:
///
/// ```dart
/// @mustBeHandled
/// Future<void> riskyOperation() async { ... }
/// ```
const mustBeHandled = MustBeHandled();
