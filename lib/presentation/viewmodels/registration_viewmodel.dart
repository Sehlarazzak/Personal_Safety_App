import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';

enum PasswordStrength { weak, fair, strong }

/// Holds the Registration screen's form state, live password-strength
/// feedback, and submit flow.
///
/// Module 1 stubbed [submit] with a simulated delay. Module 2 replaces
/// that body with a real Firebase Auth account-creation call via
/// [AuthRepository] — the View didn't need to change for this swap.
class RegistrationViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  RegistrationViewModel({required AuthRepository authRepository}) : _authRepository = authRepository;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool agreedToTerms = false;
  bool isSubmitting = false;
  String? errorMessage;

  bool get hasMinLength => passwordController.text.length >= 8;
  bool get hasUppercase => passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get hasNumber => passwordController.text.contains(RegExp(r'[0-9]'));
  bool get hasSpecialChar =>
      passwordController.text.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

  PasswordStrength get passwordStrength {
    final score = [hasMinLength, hasUppercase, hasNumber, hasSpecialChar]
        .where((e) => e)
        .length;
    if (score <= 1) return PasswordStrength.weak;
    if (score <= 3) return PasswordStrength.fair;
    return PasswordStrength.strong;
  }

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    notifyListeners();
  }

  void onPasswordChanged(String _) => notifyListeners();

  void setAgreedToTerms(bool value) {
    agreedToTerms = value;
    notifyListeners();
  }

  String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (!hasMinLength) return 'Password must be at least 8 characters';
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value != passwordController.text) return 'Passwords do not match';
    return null;
  }

  /// Returns true when registration succeeded.
  Future<bool> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;
    if (!agreedToTerms) {
      errorMessage = 'Please agree to the Terms of Service and Privacy Policy';
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.register(
        fullName: fullNameController.text,
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

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
