import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/trusted_contact_model.dart';

/// Full contact card used on the Emergency Contacts list screen — mirrors
/// `emergency_contacts/code.html`: avatar with initials, name, "Primary"
/// badge when applicable, phone number, and Edit / SMS / Call actions.
///
/// This is intentionally a separate widget from [TrustedContactTile]
/// (the compact dashboard summary row) since the two screens need
/// different levels of detail and different action sets.
class ContactCard extends StatelessWidget {
  final TrustedContactModel contact;
  final VoidCallback? onEdit;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;

  const ContactCard({
    super.key,
    required this.contact,
    this.onEdit,
    this.onCall,
    this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: contact.isPrimary
                ? AppColors.primaryContainer
                : AppColors.secondaryContainer,
            child: Text(
              contact.initials,
              style: AppTextStyles.h2.copyWith(
                color: contact.isPrimary
                    ? AppColors.onPrimaryContainer
                    : AppColors.onSecondaryContainer,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        contact.name,
                        style: AppTextStyles.h2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (contact.isPrimary) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          'Primary',
                          style: AppTextStyles.caption.copyWith(color: AppColors.onPrimaryContainer),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(contact.phoneNumber, style: AppTextStyles.bodyMd),
                const SizedBox(height: 2),
                Text(contact.relationship.label, style: AppTextStyles.caption),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            tooltip: 'Edit Contact',
            icon: const Icon(Icons.edit_outlined, color: AppColors.onSurfaceVariant),
          ),
          IconButton(
            onPressed: onMessage,
            tooltip: 'Send SMS',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.secondaryContainer,
              foregroundColor: AppColors.onSecondaryContainer,
            ),
            icon: const Icon(Icons.sms_outlined),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            onPressed: onCall,
            tooltip: 'Call ${contact.name}',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
            icon: const Icon(Icons.call),
          ),
        ],
      ),
    );
  }
}
