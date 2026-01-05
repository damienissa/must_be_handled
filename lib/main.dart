/// Entry point for the must_be_handled analyzer plugin.
///
/// This file is required by the analysis_server_plugin infrastructure.
/// It provides a top-level `plugin` variable that the Dart Analysis Server
/// uses to load and run the plugin.
library;

import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'src/rules/must_be_handled_rule.dart';

/// The plugin instance used by the Dart Analysis Server.
final plugin = MustBeHandledPlugin();

/// The main plugin class for must_be_handled.
///
/// This plugin enforces that functions annotated with `@mustBeHandled`
/// are properly handled by callers through try/catch blocks (and await
/// for async functions).
class MustBeHandledPlugin extends Plugin {
  @override
  String get name => 'must_be_handled';

  @override
  void register(PluginRegistry registry) {
    // Register as a warning rule so it's enabled by default
    registry.registerWarningRule(MustBeHandledRule());
  }
}
