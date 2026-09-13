import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../viewmodels/registration_viewmodel.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/app_shield_logo.dart';

/// Registration screen — mirrors `registration_screen/code.html`: card
/// with full name / email / password (+ live strength meter) / confirm
/// password / terms checkbox / submit / footer link back to Login.
class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RegistrationViewModel(authRepository: context.read<AuthRepository>()),
      child: const _RegistrationView(),
    );
  }
}

class _RegistrationView extends StatelessWidget {
  const _RegistrationView();

  Future<void> _handleSubmit(BuildContext context, RegistrationViewModel vm) async {
    final success = await vm.submit();
    if (success && context.mounted) {
      context.go(AppRoutes.home);
    }
  }

  Color _strengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return AppColors.error;
      case PasswordStrength.fair:
        return AppColors.tertiary;
      case PasswordStrength.strong:
        return AppColors.safe;
    }
  }

  String _strengthLabel(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.fair:
        return 'Fair';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistrationViewModel>();
    final strengthFraction = switch (vm.passwordStrength) {
      PasswordStrength.weak => 0.25,
      PasswordStrength.fair => 0.6,
      PasswordStrength.strong => 1.0,
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.marginMobile,
              vertical: AppSpacing.lg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Form(
                  key: vm.formKey,
                  child: Column(
                    children: [
                      const AppShieldLogo(size: 56),
                      const SizedBox(height: AppSpacing.sm),
                      Text('Create Account', style: AppTextStyles.displayMd.copyWith(fontSize: 26)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Join Safety Guard for personal peace of mind.',
                        style: AppTextStyles.bodyMd,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Full name
                      _labeledField(
                        label: 'Full Name',
                        child: TextFormField(
                          controller: vm.fullNameController,
                          validator: vm.validateFullName,
                          decoration: const InputDecoration(
                            hintText: 'John Doe',
                            prefixIcon: Icon(Icons.person_outline, color: AppColors.outline, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Email
                      _labeledField(
                        label: 'Email Address',
                        child: TextFormField(
                          controller: vm.emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: vm.validateEmail,
                          decoration: const InputDecoration(
                            hintText: 'john@example.com',
                            prefixIcon: Icon(Icons.mail_outline, color: AppColors.outline, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Password + strength meter
                      _labeledField(
                        label: 'Password',
                        child: TextFormField(
                          controller: vm.passwordController,
                          obscureText: !vm.isPasswordVisible,
                          validator: vm.validatePassword,
                          onChanged: vm.onPasswordChanged,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.outline, size: 20),
                            suffixIcon: IconButton(
                              onPressed: vm.togglePasswordVisibility,
                              icon: Icon(
                                vm.isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                color: AppColors.outline,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.full),
                              child: LinearProgressIndicator(
                                value: strengthFraction,
                                minHeight: 4,
                                backgroundColor: AppColors.surfaceVariant,
                                valueColor: AlwaysStoppedAnimation(_strengthColor(vm.passwordStrength)),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(_strengthLabel(vm.passwordStrength), style: AppTextStyles.caption),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.xs,
                        children: [
                          _requirementChip('8+ characters', vm.hasMinLength),
                          _requirementChip('1 uppercase', vm.hasUppercase),
                          _requirementChip('1 number', vm.hasNumber),
                          _requirementChip('1 special', vm.hasSpecialChar),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Confirm password
                      _labeledField(
                        label: 'Confirm Password',
                        child: TextFormField(
                          controller: vm.confirmPasswordController,
                          obscureText: !vm.isConfirmPasswordVisible,
                          validator: vm.validateConfirmPassword,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_reset, color: AppColors.outline, size: 20),
                            suffixIcon: IconButton(
                              onPressed: vm.toggleConfirmPasswordVisibility,
                              icon: Icon(
                                vm.isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                color: AppColors.outline,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Terms
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: vm.agreedToTerms,
                            onChanged: (value) => vm.setAgreedToTerms(value ?? false),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: AppSpacing.sm),
                              child: Text.rich(
                                TextSpan(
                                  style: AppTextStyles.caption,
                                  children: [
                                    const TextSpan(text: 'I agree to the '),
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: AppTextStyles.labelBold.copyWith(
                                        color: AppColors.primary,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: AppTextStyles.labelBold.copyWith(
                                        color: AppColors.primary,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const TextSpan(text: '.'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (vm.errorMessage != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          vm.errorMessage!,
                          style: AppTextStyles.caption.copyWith(color: AppColors.error),
                        ),
                      ],

                      const SizedBox(height: AppSpacing.sm),
                      AppPrimaryButton(
                        label: 'Create Account',
                        pillShaped: true,
                        isLoading: vm.isSubmitting,
                        onPressed: () => _handleSubmit(context, vm),
                      ),

                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account? ', style: AppTextStyles.bodyMd),
                          TextButton(
                            onPressed: () => context.pop(),
                            style: TextButton.styleFrom(padding: EdgeInsets.zero),
                            child: Text(
                              'Log in',
                              style: AppTextStyles.labelBold.copyWith(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _labeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelBold),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }

  Widget _requirementChip(String label, bool met) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          met ? Icons.check_circle : Icons.circle_outlined,
          size: 14,
          color: met ? AppColors.safe : AppColors.outlineVariant,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
