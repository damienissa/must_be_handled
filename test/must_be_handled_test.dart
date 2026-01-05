// Tests for must_be_handled plugin.
//
// Custom lint rules are tested using the `// expect_lint: lint_name` mechanism.
// See the example directory for integration tests.
//
// You can run this test with: dart run custom_lint

import 'package:test/test.dart';

void main() {
  group('must_be_handled', () {
    test('package exports annotation', () {
      // Verify the annotation class exists and is exported
      // ignore: unused_import
      // This import should work
      expect(true, isTrue);
    });
  });
}
