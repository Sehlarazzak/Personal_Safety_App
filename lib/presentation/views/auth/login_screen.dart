import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/app_shield_logo.dart';
import '../../widgets/app_text_field.dart';

/// Login screen — mirrors `login_screen/code.html`: centered shield mark,
/// "Welcome Back" heading, email + password card, forgot-password link,
/// submit button, and a footer link to Registration.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginViewModel(authRepository: context.read<AuthRepository>()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  Future<void> _handleSubmit(BuildContext context, LoginViewModel vm) async {
    final success = await vm.submit();
    if (success && context.mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();

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
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  const AppShieldLogo(size: 64),
                  const SizedBox(height: AppSpacing.md),
                  Text('Welcome Back', style: AppTextStyles.displayMd.copyWith(color: AppColors.primary)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Sign in to continue to Safety Guard.',
                    style: AppTextStyles.bodyLg,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
                    ),
                    child: Form(
                      key: vm.formKey,
                      child: Column(
                        children: [
                          AppTextField(
                            label: 'Email Address',
                            hintText: 'you@example.com',
                            leadingIcon: Icons.mail_outline,
                            controller: vm.emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: vm.validateEmail,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Password', style: AppTextStyles.labelBold),
                              TextButton(
                                onPressed: () async {
                                  final error = await vm.sendPasswordReset();
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        error ?? 'Password reset email sent. Check your inbox.',
                                      ),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                child: Text(
                                  'Forgot password?',
                                  style: AppTextStyles.labelBold.copyWith(color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            controller: vm.passwordController,
                            obscureText: !vm.isPasswordVisible,
                            validator: vm.validatePassword,
                            style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
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
                          const SizedBox(height: AppSpacing.md),
                          if (vm.errorMessage != null) ...[
                            Text(
                              vm.errorMessage!,
                              style: AppTextStyles.caption.copyWith(color: AppColors.error),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                          AppPrimaryButton(
                            label: 'Log In',
                            trailingIcon: Icons.arrow_forward,
                            isLoading: vm.isSubmitting,
                            onPressed: () => _handleSubmit(context, vm),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock, size: 16, color: AppColors.onSurfaceVariant),
                              const SizedBox(width: AppSpacing.xs),
                              Text('End-to-end encrypted connection', style: AppTextStyles.caption),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ", style: AppTextStyles.bodyMd),
                      TextButton(
                        onPressed: () => context.push(AppRoutes.register),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Text(
                          'Sign up',
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
    );
  }
}
