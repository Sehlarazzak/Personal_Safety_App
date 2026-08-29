import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Holds the Login screen's form state, validation, and submit flow.
///
/// The actual authentication call is stubbed for Module 1 — it just
/// simulates a network round-trip so the View can exercise its loading /
/// success / error states. Module 2 swaps [submit]'s body for a real
/// Firebase Auth call without changing the View.
class LoginViewModel extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isPasswordVisible = false;
  bool isSubmitting = false;
  String? errorMessage;

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  /// Returns true when the (stubbed) login succeeded so the View can
  /// navigate to the dashboard.
  Future<bool> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    // TODO(Module 2): replace with FirebaseAuth.signInWithEmailAndPassword.
    await Future.delayed(const Duration(milliseconds: 900));

    isSubmitting = false;
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
