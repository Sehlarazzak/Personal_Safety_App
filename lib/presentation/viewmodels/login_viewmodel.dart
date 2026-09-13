import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';

/// Holds the Login screen's form state, validation, and submit flow.
///
/// Module 1 stubbed [submit] with a simulated delay. Module 2 replaces
/// that body with a real call through [AuthRepository] — the View
/// (`LoginScreen`) didn't need to change at all for this swap.
class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  LoginViewModel({required AuthRepository authRepository}) : _authRepository = authRepository;

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

  /// Returns true when login succeeded so the View can navigate to the
  /// dashboard.
  Future<bool> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.signIn(
        email: emailController.text,
        password: passwordController.text,
      );
      isSubmitting = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      errorMessage = e.message;
      isSubmitting = false;
      notifyListeners();
      return false;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
      isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  /// Sends a password-reset email for whatever address is currently typed
  /// in. Returns an error string on failure, or null on success.
  Future<String?> sendPasswordReset() async {
    final email = emailController.text.trim();
    if (validateEmail(email) != null) {
      return 'Enter your email address above first.';
    }
    try {
      await _authRepository.sendPasswordResetEmail(email);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
