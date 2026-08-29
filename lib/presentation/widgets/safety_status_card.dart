import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/safety_session_status.dart';

/// Shows the current session status honestly — this is the one thing the
/// UX principles insist on: the user must always know at a glance whether
/// a session is active. Colors/icon change with [status] but never imply
/// success when nothing has happened.
class SafetyStatusCard extends StatelessWidget {
  final SafetySessionStatus status;
  final String subtitle;

  const SafetyStatusCard({
    super.key,
    required this.status,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = switch (status) {
      SafetySessionStatus.none => AppColors.secondary,
      SafetySessionStatus.active => AppColors.primary,
      SafetySessionStatus.awaitingCheckIn => AppColors.tertiary,
      SafetySessionStatus.completedSafe => AppColors.safe,
      SafetySessionStatus.escalated => AppColors.error,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(Icons.shield_outlined, size: 40, color: iconColor),
          const SizedBox(height: AppSpacing.sm),
          Text(status.label, style: AppTextStyles.h2, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle, style: AppTextStyles.bodyMd, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
