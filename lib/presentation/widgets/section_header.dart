import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Small uppercase section label used above grouped content (e.g.
/// "TRUSTED CONTACTS" on the dashboard), with an optional trailing icon
/// button such as "add contact".
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;
  final String? trailingTooltip;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailingIcon,
    this.onTrailingTap,
    this.trailingTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTextStyles.labelBold.copyWith(
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        if (trailingIcon != null)
          IconButton(
            onPressed: onTrailingTap,
            tooltip: trailingTooltip,
            icon: Icon(trailingIcon, color: AppColors.primary),
          ),
      ],
    );
  }
}
