import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';

/// The reserved "danger" button style.
///
/// Per the design system, error/red is used *exclusively* for destructive
/// or urgent actions so it keeps its meaning — this widget is the only
/// place that filled/outlined error coloring should be reached for.
/// Used for "Emergency Assistance" on the dashboard and "I Need Help" on
/// the active session screen.
class AppEmergencyButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  final bool filled;

  const AppEmergencyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.emergency,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppA11y.minTouchTarget + 16,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: filled ? AppColors.error : AppColors.errorContainer,
          foregroundColor: filled ? AppColors.onError : AppColors.onErrorContainer,
          side: filled ? BorderSide.none : const BorderSide(color: AppColors.error),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: AppSpacing.sm),
            Text(label, style: AppTextStyles.h2.copyWith(
              color: filled ? AppColors.onError : AppColors.onErrorContainer,
            )),
          ],
        ),
      ),
    );
  }
}
