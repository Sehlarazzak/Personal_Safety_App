import 'package:flutter_test/flutter_test.dart';

// `flutter create` scaffolds a default `test/widget_test.dart` that
// imports `package:<your_project_name>/main.dart` and pumps a counter-app
// `MyApp` widget. This file replaces that scaffold — the counter-app test
// doesn't apply here since `main.dart` boots `SafetyGuardApp`, not `MyApp`.
//
// A full widget smoke test of `SafetyGuardApp` isn't wired up yet on
// purpose: `SafetyGuardApp` constructs real `FirebaseAuthRepository` /
// `FirestoreContactsRepository` instances in its `MultiProvider`, which
// require `Firebase.initializeApp()` to have already run — pumping it
// directly in a plain widget test throws. Module 6 (Testing & Release
// Hardening) introduces fake repositories via `setupFirebaseAuthMocks()`
// / an in-memory `ContactsRepository` so ViewModels and screens can be
// tested without a real Firebase project. Until then, this keeps
// `flutter test` green.
//
// If you renamed this project (i.e. `pubspec.yaml`'s `name:` isn't
// `safety_guard_app`), update any real tests you add to import
// `package:<your_project_name>/...` instead.
void main() {
  test('placeholder — replace with real coverage in Module 6', () {
    expect(1 + 1, 2);
  });
}
