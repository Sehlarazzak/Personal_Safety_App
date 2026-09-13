import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/trusted_contact_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/contacts_repository.dart';
import '../../viewmodels/add_edit_contact_viewmodel.dart';

/// Add/Edit Contact screen — mirrors `add_edit_contact/code.html`: avatar
/// placeholder, Name/Phone/Relationship fields, a "Primary Emergency
/// Contact" toggle, and Save/Delete actions.
///
/// Pushed via `go_router` as a focused, back-button screen outside the
/// bottom-nav shell (per the mockup's own "no bottom nav" note). Pass an
/// existing [TrustedContactModel] as the route's `extra` to edit it;
/// omit it to create a new contact.
class AddEditContactScreen extends StatelessWidget {
  final TrustedContactModel? contact;

  const AddEditContactScreen({super.key, this.contact});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthRepository>().currentUser?.id ?? 'guest';
    return ChangeNotifierProvider(
      create: (context) => AddEditContactViewModel(
        repository: context.read<ContactsRepository>(),
        userId: userId,
        existingContact: contact,
      ),
      child: const _AddEditContactView(),
    );
  }
}

class _AddEditContactView extends StatelessWidget {
  const _AddEditContactView();

  Future<void> _handleSave(BuildContext context, AddEditContactViewModel vm) async {
    final success = await vm.submit();
    if (success && context.mounted) {
      context.pop();
    }
  }

  Future<void> _handleDelete(BuildContext context, AddEditContactViewModel vm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete contact?'),
        content: Text('${vm.nameController.text} will be removed from your emergency contacts.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final success = await vm.delete();
      if (success && context.mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddEditContactViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(vm.isEditing ? 'Edit Contact' : 'Add Contact'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar placeholder — photo upload lands in a later module.
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.outlineVariant, width: 2),
                        ),
                        child: const Icon(Icons.person_outline, size: 36, color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text('Photo coming in a later update', style: AppTextStyles.caption),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Form(
                    key: vm.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contact Name', style: AppTextStyles.labelBold),
                        const SizedBox(height: AppSpacing.xs),
                        TextFormField(
                          controller: vm.nameController,
                          validator: vm.validateName,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Jane Doe',
                            prefixIcon: Icon(Icons.person_outline, color: AppColors.outline, size: 20),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        Text('Phone Number', style: AppTextStyles.labelBold),
                        const SizedBox(height: AppSpacing.xs),
                        TextFormField(
                          controller: vm.phoneController,
                          keyboardType: TextInputType.phone,
                          validator: vm.validatePhone,
                          decoration: const InputDecoration(
                            hintText: '+1 (555) 000-0000',
                            prefixIcon: Icon(Icons.call_outlined, color: AppColors.outline, size: 20),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        Text.rich(
                          TextSpan(
                            style: AppTextStyles.labelBold,
                            children: [
                              const TextSpan(text: 'Relationship '),
                              TextSpan(
                                text: '(Optional)',
                                style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        DropdownButtonFormField<ContactRelationship>(
                          // Using `value:` rather than the newer `initialValue:`
                          // for compatibility with the README's stated Flutter
                          // 3.22+ minimum.
                          value: vm.relationship,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.group_outlined, color: AppColors.outline, size: 20),
                          ),
                          items: ContactRelationship.values
                              .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) vm.setRelationship(value);
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),

                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Primary Emergency Contact', style: AppTextStyles.labelBold),
                                    Text('Notify first during an SOS event', style: AppTextStyles.caption),
                                  ],
                                ),
                              ),
                              Switch(
                                value: vm.isPrimary,
                                onChanged: vm.setIsPrimary,
                                // `activeColor` (rather than the newer
                                // `activeThumbColor`) for compatibility with
                                // the README's stated Flutter 3.22+ minimum.
                                activeColor: AppColors.onPrimary,
                                activeTrackColor: AppColors.primary,
                              ),
                            ],
                          ),
                        ),

                        if (vm.errorMessage != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(vm.errorMessage!, style: AppTextStyles.caption.copyWith(color: AppColors.error)),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),
                ElevatedButton.icon(
                  onPressed: vm.isSubmitting ? null : () => _handleSave(context, vm),
                  icon: vm.isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Save Contact'),
                ),
                if (vm.isEditing) ...[
                  const SizedBox(height: AppSpacing.sm),
                  TextButton.icon(
                    onPressed: vm.isSubmitting ? null : () => _handleDelete(context, vm),
                    icon: Icon(Icons.delete_outline, color: AppColors.error),
                    label: Text('Delete Contact', style: TextStyle(color: AppColors.error)),
                    style: TextButton.styleFrom(
                      minimumSize: const Size.fromHeight(AppA11y.minTouchTarget),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
