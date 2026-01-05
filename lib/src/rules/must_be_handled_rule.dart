import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/dart/error/lint_codes.dart'; // ignore: implementation_imports

/// Analysis rule that enforces explicit error handling for functions
/// annotated with `@mustBeHandled`.
///
/// This rule reports an error when:
/// - A sync function annotated with `@mustBeHandled` is called outside a try/catch
/// - An async function annotated with `@mustBeHandled` is called without await
/// - An async function annotated with `@mustBeHandled` is awaited outside a try/catch
class MustBeHandledRule extends MultiAnalysisRule {
  /// Diagnostic code for sync functions not wrapped in try/catch.
  static const LintCode syncNotHandled = LintCode(
    'must_be_handled_violation',
    "Call to '{0}' is annotated with @mustBeHandled and must be wrapped in "
        'try/catch.',
    correctionMessage: 'Wrap this call in a try/catch block.',
    uniqueName: 'LintCode.must_be_handled_sync_not_handled',
  );

  /// Diagnostic code for async functions not awaited.
  static const LintCode asyncNotAwaited = LintCode(
    'must_be_handled_violation',
    "Call to '{0}' is annotated with @mustBeHandled and must be awaited and "
        'wrapped in try/catch.',
    correctionMessage:
        'Add await before this call and wrap it in a try/catch block.',
    uniqueName: 'LintCode.must_be_handled_async_not_awaited',
  );

  /// Diagnostic code for async functions awaited but not in try/catch.
  static const LintCode asyncNotHandled = LintCode(
    'must_be_handled_violation',
    "Call to '{0}' is annotated with @mustBeHandled. The await must be "
        'wrapped in try/catch.',
    correctionMessage: 'Wrap this await expression in a try/catch block.',
    uniqueName: 'LintCode.must_be_handled_async_not_handled',
  );

  /// Creates a new [MustBeHandledRule] instance.
  MustBeHandledRule()
    : super(
        name: 'must_be_handled_violation',
        description:
            'Enforces that functions annotated with @mustBeHandled are '
            'properly handled with try/catch (and await for async functions).',
      );

  @override
  List<LintCode> get diagnosticCodes => [
    syncNotHandled,
    asyncNotAwaited,
    asyncNotHandled,
  ];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _MustBeHandledVisitor(this, context);
    registry.addMethodInvocation(this, visitor);
    registry.addFunctionExpressionInvocation(this, visitor);
  }
}

/// Visitor that checks method and function invocations for proper handling.
class _MustBeHandledVisitor extends SimpleAstVisitor<void> {
  final MustBeHandledRule rule;
  final RuleContext context;

  _MustBeHandledVisitor(this.rule, this.context);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    _checkInvocation(node, node.methodName.element);
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    final function = node.function;
    Element? element;

    if (function is Identifier) {
      element = function.element;
    } else if (function is PropertyAccess) {
      element = function.propertyName.element;
    }

    _checkInvocation(node, element);
  }

  /// Checks if the invocation of [element] at [node] is properly handled.
  void _checkInvocation(Expression node, Element? element) {
    if (element == null) return;

    // Check if the element has @mustBeHandled annotation
    if (!_hasMustBeHandledAnnotation(element)) return;

    // Determine if this is an async function (returns Future)
    final isAsync = _isAsyncFunction(element);

    if (isAsync) {
      _checkAsyncInvocation(node);
    } else {
      _checkSyncInvocation(node);
    }
  }

  /// Checks if [element] has the @mustBeHandled annotation.
  bool _hasMustBeHandledAnnotation(Element element) {
    for (final annotation in element.metadata.annotations) {
      final annotationElement = annotation.element;
      if (annotationElement == null) continue;

      // Check for const variable reference (e.g., @mustBeHandled)
      if (annotationElement is GetterElement) {
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

    // Check if the return type is Future or FutureOr
    return _isFutureType(returnType);
  }

  /// Checks if [type] is Future, FutureOr, or a subtype thereof.
  bool _isFutureType(DartType type) {
    if (type is InterfaceType) {
      final element = type.element;
      final name = element.name;

      // Check for Future or FutureOr from dart:async
      if ((name == 'Future' || name == 'FutureOr') &&
          element.library.name == 'dart.async') {
        return true;
      }
    }

    return false;
  }

  /// Checks a sync invocation for proper try/catch handling.
  void _checkSyncInvocation(Expression node) {
    if (!_isInsideTryCatchBody(node)) {
      rule.reportAtNode(
        node,
        diagnosticCode: MustBeHandledRule.syncNotHandled,
        arguments: [_getInvocationName(node)],
      );
    }
  }

  /// Checks an async invocation for proper await and try/catch handling.
  void _checkAsyncInvocation(Expression node) {
    final awaitExpression = _findParentAwaitExpression(node);

    if (awaitExpression == null) {
      // Not awaited at all
      rule.reportAtNode(
        node,
        diagnosticCode: MustBeHandledRule.asyncNotAwaited,
        arguments: [_getInvocationName(node)],
      );
    } else if (!_isInsideTryCatchBody(awaitExpression)) {
      // Awaited but not in try/catch
      rule.reportAtNode(
        node,
        diagnosticCode: MustBeHandledRule.asyncNotHandled,
        arguments: [_getInvocationName(node)],
      );
    }
  }

  /// Finds the parent AwaitExpression if the node is directly awaited.
  AwaitExpression? _findParentAwaitExpression(Expression node) {
    AstNode? current = node.parent;

    while (current != null) {
      if (current is AwaitExpression) {
        return current;
      }

      // Stop if we hit a boundary that would break the direct await relationship
      if (current is Statement ||
          current is FunctionBody ||
          current is VariableDeclaration) {
        break;
      }

      // Continue through parenthesized expressions and other wrappers
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

  /// Checks if [node] is inside the body of a try statement (not in finally).
  bool _isInsideTryCatchBody(AstNode node) {
    AstNode? current = node.parent;

    while (current != null) {
      if (current is TryStatement) {
        // Check if the node is in the try body (not in catch or finally)
        return _isDescendantOf(node, current.body);
      }

      // Stop at function boundaries
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
      if (function is Identifier) {
        return function.name;
      }
    }

    return '<unknown>';
  }
}
