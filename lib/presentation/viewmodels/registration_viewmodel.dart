import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum PasswordStrength { weak, fair, strong }

/// Holds the Registration screen's form state, live password-strength
/// feedback, and submit flow. Backend account creation is stubbed for
/// Module 1 (see [submit]) and will be wired to Firebase Auth in Module 2.
class RegistrationViewModel extends ChangeNotifier {
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

  /// Returns true when the (stubbed) registration succeeded.
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

    // TODO(Module 2): replace with FirebaseAuth.createUserWithEmailAndPassword
    // plus writing the user profile document.
    await Future.delayed(const Duration(milliseconds: 900));

    isSubmitting = false;
    notifyListeners();
    return true;
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
