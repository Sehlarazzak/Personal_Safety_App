import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';

/// Persistent top bar for authenticated tabs (Home, Contacts, History).
/// Shows a small avatar + app name on the left and a quick settings
/// shortcut on the right, matching `home_dashboard/code.html`.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String? avatarUrl;
  final VoidCallback? onSettingsTap;

  const AppTopBar({super.key, this.avatarUrl, this.onSettingsTap});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.marginMobile,
        vertical: AppSpacing.sm,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.surfaceContainerHigh,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null
                  ? const Icon(Icons.person, color: AppColors.onSurfaceVariant)
                  : null,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text('Safety Guard', style: AppTextStyles.h1.copyWith(color: AppColors.primary)),
            const Spacer(),
            IconButton(
              onPressed: onSettingsTap,
              tooltip: 'Settings',
              icon: const Icon(Icons.settings, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
