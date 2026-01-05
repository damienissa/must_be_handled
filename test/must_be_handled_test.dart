import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:must_be_handled/src/rules/must_be_handled_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(MustBeHandledRuleSyncTest);
    defineReflectiveTests(MustBeHandledRuleAsyncTest);
    defineReflectiveTests(MustBeHandledRuleNestedTest);
  });
}

@reflectiveTest
class MustBeHandledRuleSyncTest extends AnalysisRuleTest {
  @override
  void setUp() {
    newPackage('must_be_handled').addFile('lib/must_be_handled.dart', r'''
class MustBeHandled {
  const MustBeHandled();
}

const mustBeHandled = MustBeHandled();
''');
    rule = MustBeHandledRule();
    super.setUp();
  }

  Future<void> test_sync_not_in_try_catch() async {
    await assertDiagnostics(
      r'''
import 'package:must_be_handled/must_be_handled.dart';

@mustBeHandled
void danger() {}

void main() {
  danger();
}
''',
      [lint(105, 8)],
    );
  }

  Future<void> test_sync_in_try_catch_valid() async {
    await assertNoDiagnostics(r'''
import 'package:must_be_handled/must_be_handled.dart';

@mustBeHandled
void danger() {}

void main() {
  try {
    danger();
  } catch (_) {}
}
''');
  }

  Future<void> test_sync_in_finally_invalid() async {
    await assertDiagnostics(
      r'''
import 'package:must_be_handled/must_be_handled.dart';

@mustBeHandled
void danger() {}

void main() {
  try {
  } finally {
    danger();
  }
}
''',
      [lint(129, 8)],
    );
  }

  Future<void> test_sync_in_catch_invalid() async {
    await assertDiagnostics(
      r'''
import 'package:must_be_handled/must_be_handled.dart';

@mustBeHandled
void danger() {}

void main() {
  try {
  } catch (_) {
    danger();
  }
}
''',
      [lint(131, 8)],
    );
  }

  Future<void> test_sync_outside_try_body_invalid() async {
    await assertDiagnostics(
      r'''
import 'package:must_be_handled/must_be_handled.dart';

@mustBeHandled
void danger() {}

void main() {
  danger();
  try {
  } catch (_) {}
}
''',
      [lint(105, 8)],
    );
  }

  Future<void> test_sync_no_annotation_valid() async {
    await assertNoDiagnostics(r'''
void safe() {}

void main() {
  safe();
}
''');
  }

  Future<void> test_sync_with_constructor_annotation() async {
    await assertDiagnostics(
      r'''
import 'package:must_be_handled/must_be_handled.dart';

@MustBeHandled()
void danger() {}

void main() {
  danger();
}
''',
      [lint(107, 8)],
    );
  }
}

@reflectiveTest
class MustBeHandledRuleAsyncTest extends AnalysisRuleTest {
  @override
  void setUp() {
    newPackage('must_be_handled').addFile('lib/must_be_handled.dart', r'''
class MustBeHandled {
  const MustBeHandled();
}

const mustBeHandled = MustBeHandled();
''');
    rule = MustBeHandledRule();
    super.setUp();
  }

  Future<void> test_async_not_awaited() async {
    await assertDiagnostics(
      r'''
import 'package:must_be_handled/must_be_handled.dart';

@mustBeHandled
Future<void> fetchUser() async {}

void main() {
  fetchUser();
}
''',
      [lint(122, 11)],
    );
  }

  Future<void> test_async_awaited_not_in_try_catch() async {
    await assertDiagnostics(
      r'''
import 'package:must_be_handled/must_be_handled.dart';

@mustBeHandled
Future<void> fetchUser() async {}

void main() async {
  await fetchUser();
}
''',
      [lint(134, 11)],
    );
  }

  Future<void> test_async_awaited_in_try_catch_valid() async {
    await assertNoDiagnostics(r'''
import 'package:must_be_handled/must_be_handled.dart';

@mustBeHandled
Future<void> fetchUser() async {}

void main() async {
  try {
    await fetchUser();
  } catch (_) {}
}
''');
  }

  Future<void> test_async_not_awaited_in_try_catch_invalid() async {
    await assertDiagnostics(
      r'''
import 'package:must_be_handled/must_be_handled.dart';

@mustBeHandled
Future<void> fetchUser() async {}

void main() {
  try {
    fetchUser();
  } catch (_) {}
}
''',
      [lint(132, 11)],
    );
  }

  Future<void> test_async_no_annotation_valid() async {
    await assertNoDiagnostics(r'''
Future<void> safe() async {}

void main() async {
  await safe();
  safe();
}
''');
  }

  Future<void> test_async_returning_value_valid() async {
    await assertNoDiagnostics(r'''
import 'package:must_be_handled/must_be_handled.dart';

@mustBeHandled
Future<String> fetchUser() async => 'user';

void main() async {
  try {
    var user = await fetchUser();
    print(user);
  } catch (_) {}
}
''');
  }
}

@reflectiveTest
class MustBeHandledRuleNestedTest extends AnalysisRuleTest {
  @override
  void setUp() {
    newPackage('must_be_handled').addFile('lib/must_be_handled.dart', r'''
class MustBeHandled {
  const MustBeHandled();
}

const mustBeHandled = MustBeHandled();
''');
    rule = MustBeHandledRule();
    super.setUp();
  }

  Future<void> test_nested_try_catch_valid() async {
    await assertNoDiagnostics(r'''
import 'package:must_be_handled/must_be_handled.dart';

@mustBeHandled
void danger() {}

void main() {
  try {
    try {
      danger();
    } catch (_) {}
  } catch (_) {}
}
''');
  }

  Future<void> test_inner_try_valid_outer_not() async {
    await assertNoDiagnostics(r'''
import 'package:must_be_handled/must_be_handled.dart';

@mustBeHandled
void danger() {}

void main() {
  try {
    danger();
  } catch (_) {
    try {
    } catch (_) {}
  }
}
''');
  }

  Future<void> test_method_invocation_on_object() async {
    await assertDiagnostics(
      r'''
import 'package:must_be_handled/must_be_handled.dart';

class Service {
  @mustBeHandled
  void danger() {}
}

void main() {
  Service().danger();
}
''',
      [lint(127, 18)],
    );
  }

  Future<void> test_method_invocation_on_object_valid() async {
    await assertNoDiagnostics(r'''
import 'package:must_be_handled/must_be_handled.dart';

class Service {
  @mustBeHandled
  void danger() {}
}

void main() {
  try {
    Service().danger();
  } catch (_) {}
}
''');
  }
}
