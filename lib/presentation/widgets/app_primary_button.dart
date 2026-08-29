import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';

/// Standard filled primary-action button.
///
/// Used for things like "Log In", "Create Account", and "Start Safety
/// Session". Height and shape follow the design system: 48px minimum
/// touch target, pill-shaped for the dashboard's hero CTAs, rounded-8
/// otherwise.
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;
  final IconData? leadingIcon;
  final bool isLoading;
  final bool pillShaped;
  final double height;

  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.trailingIcon,
    this.leadingIcon,
    this.isLoading = false,
    this.pillShaped = false,
    this.height = AppA11y.minTouchTarget,
  });

  @override
  Widget build(BuildContext context) {
    final radius = pillShaped ? AppRadius.full : AppRadius.defaultRadius;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.outlineVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          elevation: 1,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(AppColors.onPrimary),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leadingIcon != null) ...[
                    Icon(leadingIcon, size: 22),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(label, style: AppTextStyles.labelBold.copyWith(
                    color: AppColors.onPrimary,
                    fontSize: pillShaped ? 18 : 14,
                  )),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Icon(trailingIcon, size: 22),
                  ],
                ],
              ),
      ),
    );
  }
}
