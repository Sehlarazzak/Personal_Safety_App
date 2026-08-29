import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';

/// Generic "coming in a later module" screen.
///
/// Module 1 only needs Contacts / History / Settings to *exist* as
/// navigable destinations behind the bottom nav so the app shell is
/// complete end-to-end. Modules 2 (Contacts), 5 (History, Settings) fill
/// these in with real screens using the same MVVM structure.
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String moduleNote;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.moduleNote,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.outline),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: AppTextStyles.h1, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(
              moduleNote,
              style: AppTextStyles.bodyMd,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
