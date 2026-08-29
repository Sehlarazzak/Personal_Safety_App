import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../viewmodels/splash_viewmodel.dart';
import '../../widgets/app_shield_logo.dart';

/// Splash screen — brand moment + simulated session check.
/// Mirrors `splash_screen/code.html`: centered shield mark, app name,
/// tagline, a restrained spinner with rotating status text, and an
/// "end-to-end encrypted" trust indicator at the bottom.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SplashViewModel()..startBootSequence(),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SplashViewModel>();

    // Navigate once the boot sequence finishes. Module 2 will branch this
    // on vm.isAuthenticated to skip straight to Home for returning users.
    if (vm.isReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(AppRoutes.login);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Ambient watermark shield, faint, behind everything.
          Positioned.fill(
            child: Center(
              child: Opacity(
                opacity: 0.05,
                child: Icon(Icons.shield, size: 400, color: AppColors.primary),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.marginMobile,
                vertical: AppSpacing.xl,
              ),
              child: Column(
                children: [
                  const Spacer(),
                  const AppShieldLogo(size: 96, icon: Icons.shield),
                  const SizedBox(height: AppSpacing.md),
                  Text('Safety Guard', style: AppTextStyles.displayMd.copyWith(color: AppColors.primary)),
                  const SizedBox(height: AppSpacing.sm),
                  const SizedBox(
                    width: 280,
                    child: Text(
                      'Securing your personal safety network.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMd,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      vm.statusMessage,
                      key: ValueKey(vm.statusMessage),
                      style: AppTextStyles.labelBold.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Opacity(
                    opacity: 0.6,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock, size: 16, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: AppSpacing.xs),
                        Text('End-to-End Encrypted', style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
