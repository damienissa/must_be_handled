import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart' show DiagnosticSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Lint rule for sync functions annotated with @mustBeHandled that are
/// not wrapped in try/catch.
class MustBeHandledSyncRule extends DartLintRule {
  MustBeHandledSyncRule() : super(code: _code);

  static const _code = LintCode(
    name: 'must_be_handled_sync',
    problemMessage:
        "Call to '{0}' is annotated with @mustBeHandled and must be wrapped "
        'in try/catch.',
    correctionMessage: 'Wrap this call in a try/catch block.',
    errorSeverity: DiagnosticSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      _checkSyncInvocation(node, node.methodName.element, reporter);
    });

    context.registry.addFunctionExpressionInvocation((node) {
      final function = node.function;
      Element? element;

      if (function is SimpleIdentifier) {
        element = function.element;
      } else if (function is PropertyAccess) {
        element = function.propertyName.element;
      }

      _checkSyncInvocation(node, element, reporter);
    });
  }

  void _checkSyncInvocation(
    Expression node,
    Element? element,
    ErrorReporter reporter,
  ) {
    if (element == null) return;
    if (!_hasMustBeHandledAnnotation(element)) return;
    if (_isAsyncFunction(element)) return; // Skip async functions

    if (!_isInsideTryCatchBody(node)) {
      reporter.atNode(node, code, arguments: [_getInvocationName(node)]);
    }
  }
}

/// Lint rule for async functions annotated with @mustBeHandled that are
/// not awaited.
class MustBeHandledAsyncNotAwaitedRule extends DartLintRule {
  MustBeHandledAsyncNotAwaitedRule() : super(code: _code);

  static const _code = LintCode(
    name: 'must_be_handled_async_not_awaited',
    problemMessage:
        "Call to '{0}' is annotated with @mustBeHandled and must be awaited "
        'and wrapped in try/catch.',
    correctionMessage:
        'Add await before this call and wrap it in a try/catch block.',
    errorSeverity: DiagnosticSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      _checkAsyncNotAwaited(node, node.methodName.element, reporter);
    });

    context.registry.addFunctionExpressionInvocation((node) {
      final function = node.function;
      Element? element;

      if (function is SimpleIdentifier) {
        element = function.element;
      } else if (function is PropertyAccess) {
        element = function.propertyName.element;
      }

      _checkAsyncNotAwaited(node, element, reporter);
    });
  }

  void _checkAsyncNotAwaited(
    Expression node,
    Element? element,
    ErrorReporter reporter,
  ) {
    if (element == null) return;
    if (!_hasMustBeHandledAnnotation(element)) return;
    if (!_isAsyncFunction(element)) return; // Only async functions

    final awaitExpression = _findParentAwaitExpression(node);
    if (awaitExpression == null) {
      reporter.atNode(node, code, arguments: [_getInvocationName(node)]);
    }
  }
}

/// Lint rule for async functions annotated with @mustBeHandled that are
/// awaited but not wrapped in try/catch.
class MustBeHandledAsyncNotHandledRule extends DartLintRule {
  MustBeHandledAsyncNotHandledRule() : super(code: _code);

  static const _code = LintCode(
    name: 'must_be_handled_async_not_handled',
    problemMessage:
        "Call to '{0}' is annotated with @mustBeHandled. The await must be "
        'wrapped in try/catch.',
    correctionMessage: 'Wrap this await expression in a try/catch block.',
    errorSeverity: DiagnosticSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      _checkAsyncNotHandled(node, node.methodName.element, reporter);
    });

    context.registry.addFunctionExpressionInvocation((node) {
      final function = node.function;
      Element? element;

      if (function is SimpleIdentifier) {
        element = function.element;
      } else if (function is PropertyAccess) {
        element = function.propertyName.element;
      }

      _checkAsyncNotHandled(node, element, reporter);
    });
  }

  void _checkAsyncNotHandled(
    Expression node,
    Element? element,
    ErrorReporter reporter,
  ) {
    if (element == null) return;
    if (!_hasMustBeHandledAnnotation(element)) return;
    if (!_isAsyncFunction(element)) return; // Only async functions

    final awaitExpression = _findParentAwaitExpression(node);
    if (awaitExpression != null && !_isInsideTryCatchBody(awaitExpression)) {
      reporter.atNode(node, code, arguments: [_getInvocationName(node)]);
    }
  }
}

// ============================================================================
// Shared utility functions
// ============================================================================

/// Checks if [element] has the @mustBeHandled annotation.
bool _hasMustBeHandledAnnotation(Element element) {
  for (final annotation in element.metadata.annotations) {
    final annotationElement = annotation.element;
    if (annotationElement == null) continue;

    // Check for const variable reference (e.g., @mustBeHandled)
    if (annotationElement is PropertyAccessorElement) {
      final variable = annotationElement.variable;
      final name = variable.name;
      if (name == 'mustBeHandled') {
        final library = variable.library;
        if (library.identifier.startsWith('package:must_be_handled/')) {
          return true;
        }
      }
    }

    // Check for constructor invocation (e.g., @MustBeHandled())
    if (annotationElement is ConstructorElement) {
      final classElement = annotationElement.enclosingElement;
      if (classElement.name == 'MustBeHandled') {
        final library = classElement.library;
        if (library.identifier.startsWith('package:must_be_handled/')) {
          return true;
        }
      }
    }
  }

  return false;
}

/// Checks if [element] is an async function (returns Future).
bool _isAsyncFunction(Element element) {
  DartType? returnType;

  if (element is ExecutableElement) {
    returnType = element.returnType;
  }

  if (returnType == null) return false;

  return _isFutureType(returnType);
}

/// Checks if [type] is Future, FutureOr, or a subtype thereof.
bool _isFutureType(DartType type) {
  if (type is InterfaceType) {
    final element = type.element;
    final name = element.name;

    if ((name == 'Future' || name == 'FutureOr') &&
        element.library.name == 'dart.async') {
      return true;
    }
  }

  return false;
}

/// Finds the parent AwaitExpression if the node is directly awaited.
AwaitExpression? _findParentAwaitExpression(Expression node) {
  AstNode? current = node.parent;

  while (current != null) {
    if (current is AwaitExpression) {
      return current;
    }

    if (current is Statement ||
        current is FunctionBody ||
        current is VariableDeclaration) {
      break;
    }

    if (current is ParenthesizedExpression ||
        current is Expression ||
        current is ArgumentList) {
      current = current.parent;
      continue;
    }

    break;
  }

  return null;
}

/// Checks if [node] is inside the body of a try statement.
bool _isInsideTryCatchBody(AstNode node) {
  AstNode? current = node.parent;

  while (current != null) {
    if (current is TryStatement) {
      return _isDescendantOf(node, current.body);
    }

    if (current is FunctionBody) break;

    current = current.parent;
  }

  return false;
}

/// Checks if [node] is a descendant of [potentialAncestor].
bool _isDescendantOf(AstNode node, AstNode potentialAncestor) {
  AstNode? current = node.parent;

  while (current != null) {
    if (current == potentialAncestor) return true;
    current = current.parent;
  }

  return false;
}

/// Gets the name of the invoked function/method for error messages.
String _getInvocationName(Expression node) {
  if (node is MethodInvocation) {
    return node.methodName.name;
  } else if (node is FunctionExpressionInvocation) {
    final function = node.function;
    if (function is SimpleIdentifier) {
      return function.name;
    }
  }

  return '<unknown>';
}
