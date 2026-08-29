import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/trusted_contact_model.dart';

/// A single trusted-contact row with a quick "call" action.
///
/// Design system requires rows to be at least 64px tall so the call
/// button stays easy to hit under stress — enforced here via padding
/// rather than left to each screen to remember.
class TrustedContactTile extends StatelessWidget {
  final TrustedContactModel contact;
  final VoidCallback? onCall;
  final VoidCallback? onTap;

  const TrustedContactTile({
    super.key,
    required this.contact,
    this.onCall,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.secondaryContainer,
                child: Icon(Icons.person, color: AppColors.onSecondaryContainer),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contact.name, style: AppTextStyles.labelBold),
                    Text(
                      contact.isPrimary ? 'Primary Contact' : 'Trusted Contact',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onCall,
                tooltip: 'Call ${contact.name}',
                icon: const Icon(Icons.call, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
