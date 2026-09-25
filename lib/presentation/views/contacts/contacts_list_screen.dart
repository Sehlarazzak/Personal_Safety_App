import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/services/contact_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/contacts_repository.dart';
import '../../viewmodels/contacts_viewmodel.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/contact_card.dart';

/// Emergency Contacts tab — mirrors `emergency_contacts/code.html`:
/// intro copy, a live list of trusted contacts with Edit/SMS/Call
/// actions, a prominent "Add New Contact" CTA, and an empty state for
/// first-time users.
///
/// Lives inside [MainShellScreen]'s `IndexedStack`, same as the Home tab —
/// it is not itself a routed screen. [AddEditContactScreen] (pushed via
/// go_router) is where the actual add/edit form lives.
class ContactsListScreen extends StatelessWidget {
  const ContactsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthRepository>().currentUser?.id ?? 'guest';
    return ChangeNotifierProvider(
      create: (context) => ContactsViewModel(
        repository: context.read<ContactsRepository>(),
        userId: userId,
      ),
      child: const _ContactsListView(),
    );
  }
}

class _ContactsListView extends StatelessWidget {
  const _ContactsListView();

  Future<void> _handleCall(BuildContext context, String phoneNumber) async {
    try {
      await context.read<ContactLauncher>().launchCall(phoneNumber);
    } on LaunchException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _handleMessage(BuildContext context, String phoneNumber, String name) async {
    try {
      await context.read<ContactLauncher>().launchSms(
            phoneNumber,
            "Hi $name, checking in — just wanted you to know I'm safe.",
          );
    } on LaunchException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  /// Shows a confirmation dialog and deletes the contact if confirmed.
  /// Returns whether the swipe-to-delete gesture should complete (true)
  /// or snap back (false) — required by [Dismissible.confirmDismiss].
  Future<bool> _confirmDelete(BuildContext context, ContactsViewModel vm, String contactId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove contact?'),
        content: Text('$name will no longer be notified during an emergency.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Remove', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await vm.deleteContact(contactId);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ContactsViewModel>();

    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.marginMobile,
          vertical: AppSpacing.lg,
        ),
        children: [
          Text('Emergency Contacts', style: AppTextStyles.displayMd.copyWith(fontSize: 28)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'These contacts are notified with your location if you activate an SOS alert or miss a check-in.',
            style: AppTextStyles.bodyMd,
          ),
          if (vm.contacts.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text('Swipe a contact left to remove it.', style: AppTextStyles.caption),
          ],
          const SizedBox(height: AppSpacing.lg),

          if (vm.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          else if (vm.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text(vm.errorMessage!, style: AppTextStyles.bodyMd.copyWith(color: AppColors.error)),
            )
          else if (vm.contacts.isEmpty)
            _EmptyState(onAddContact: () => context.push(AppRoutes.addContact))
          else ...[
            for (final contact in vm.contacts) ...[
              Dismissible(
                key: ValueKey(contact.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _confirmDelete(context, vm, contact.id, contact.name),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(Icons.delete_outline, color: AppColors.onErrorContainer),
                ),
                child: ContactCard(
                  contact: contact,
                  onEdit: () => context.push(AppRoutes.editContact, extra: contact),
                  onCall: () => _handleCall(context, contact.phoneNumber),
                  onMessage: () => _handleMessage(context, contact.phoneNumber, contact.name),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: AppSpacing.sm),
            AppPrimaryButton(
              label: 'Add New Contact',
              leadingIcon: Icons.person_add,
              onPressed: () => context.push(AppRoutes.addContact),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddContact;

  const _EmptyState({required this.onAddContact});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: AppColors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.group_off, size: 44, color: AppColors.onSecondaryContainer),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('No Contacts Added', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.xs),
          Text(
            "You haven't set up any emergency contacts yet. Add trusted friends or family who should be alerted in an emergency.",
            style: AppTextStyles.bodyMd,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: onAddContact,
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Contact'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 2),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
          ),
        ],
      ),
    );
  }
}
