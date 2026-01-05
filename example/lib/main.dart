// ignore_for_file: unused_local_variable, avoid_print

import 'package:must_be_handled/must_be_handled.dart';

/// Example of a sync function that must be handled.
@mustBeHandled
void dangerousSync() {
  throw Exception('Something went wrong!');
}

/// Example of an async function that must be handled.
@mustBeHandled
Future<String> fetchUser() async {
  throw Exception('Network error!');
}

/// Example of using @MustBeHandled() constructor annotation.
@MustBeHandled()
Future<void> riskyOperation() async {
  throw Exception('Operation failed!');
}

void main() async {
  // ✅ Valid - sync function in try/catch
  try {
    dangerousSync();
  } catch (e) {
    print('Caught sync error: $e');
  }

  // ✅ Valid - async function awaited in try/catch
  try {
    final user = await fetchUser();
    print('User: $user');
  } catch (e) {
    print('Caught async error: $e');
  }

  // ✅ Valid - async function with constructor annotation, awaited in try/catch
  try {
    await riskyOperation();
  } catch (e) {
    print('Caught risky operation error: $e');
  }

  // The following would trigger analyzer errors:

  // ❌ Invalid - sync function not in try/catch
  dangerousSync();

  // ❌ Invalid - async function not awaited
  fetchUser();

  // ❌ Invalid - async function awaited but not in try/catch
  await fetchUser();

  // ❌ Invalid - async function not awaited (false safety)
  try {
    fetchUser(); // not awaited!
  } catch (_) {}
}
