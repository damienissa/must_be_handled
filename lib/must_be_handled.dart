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
/// dev_dependencies:
///   custom_lint: ^0.8.1
///   must_be_handled: ^0.1.0
/// ```
///
/// Then enable custom_lint in your `analysis_options.yaml`:
///
/// ```yaml
/// analyzer:
///   plugins:
///     - custom_lint
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

import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/rules/must_be_handled_rule.dart';

export 'src/annotation.dart';

/// Creates the custom_lint plugin instance.
///
/// This is the entry point for the custom_lint plugin infrastructure.
PluginBase createPlugin() => _MustBeHandledPlugin();

/// The main plugin class for must_be_handled.
class _MustBeHandledPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    MustBeHandledSyncRule(),
    MustBeHandledAsyncNotAwaitedRule(),
    MustBeHandledAsyncNotHandledRule(),
  ];
}
