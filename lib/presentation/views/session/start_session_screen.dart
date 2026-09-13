import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/trusted_contact_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/contacts_repository.dart';
import '../../viewmodels/start_session_viewmodel.dart';

/// "Start Session" screen — mirrors `start_safety_session/code.html`:
/// duration presets, optional trip notes, a guardian-contact summary card,
/// and a fixed-bottom "Start Safety Session" CTA.
class StartSessionScreen extends StatelessWidget {
  const StartSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthRepository>().currentUser?.id ?? 'guest';
    return ChangeNotifierProvider(
      create: (context) => StartSessionViewModel(
        contactsRepository: context.read<ContactsRepository>(),
        sessionController: context.read<SessionController>(),
        userId: userId,
      ),
      child: const _StartSessionView(),
    );
  }
}

class _StartSessionView extends StatelessWidget {
  const _StartSessionView();

  Future<void> _promptCustomDuration(BuildContext context, StartSessionViewModel vm) async {
    final controller = TextEditingController(
      text: vm.isCustomDuration ? vm.selectedDurationMinutes.toString() : '',
    );
    final minutes = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Custom duration'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(suffixText: 'minutes'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(int.tryParse(controller.text)),
            child: const Text('Set'),
          ),
        ],
      ),
    );
    if (minutes != null && minutes > 0) {
      vm.setCustomDuration(minutes);
    }
  }

  Future<void> _pickGuardian(BuildContext context, StartSessionViewModel vm) async {
    final chosen = await showModalBottomSheet<TrustedContactModel>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text('Notify which contact?', style: AppTextStyles.h2),
            ),
            for (final contact in vm.contacts)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.secondaryContainer,
                  child: Text(contact.initials, style: AppTextStyles.labelBold),
                ),
                title: Text(contact.name),
                subtitle: Text(contact.relationship.label),
                onTap: () => Navigator.of(sheetContext).pop(contact),
              ),
          ],
        ),
      ),
    );
    if (chosen != null) vm.selectGuardian(chosen);
  }

  Future<void> _handleStart(BuildContext context, StartSessionViewModel vm) async {
    final started = await vm.startSession();
    if (started && context.mounted) {
      context.pushReplacement(AppRoutes.activeSession);
    } else if (vm.errorMessage != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StartSessionViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Safety Guard')),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginMobile,
                AppSpacing.lg,
                AppSpacing.marginMobile,
                120, // room for the fixed bottom CTA
              ),
              children: [
                Text('Start Session', style: AppTextStyles.displayMd.copyWith(fontSize: 30)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Set a duration and share your status with trusted contacts.',
                  style: AppTextStyles.bodyMd,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Duration selector
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, color: AppColors.primary),
                          const SizedBox(width: AppSpacing.xs),
                          Text('Duration', style: AppTextStyles.h2),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: AppSpacing.sm,
                        mainAxisSpacing: AppSpacing.sm,
                        childAspectRatio: 0.9,
                        children: [
                          for (final preset in StartSessionViewModel.durationPresets)
                            _DurationChip(
                              label: '$preset',
                              unit: 'min',
                              selected: !vm.isCustomDuration && vm.selectedDurationMinutes == preset,
                              onTap: () => vm.selectPresetDuration(preset),
                            ),
                          _DurationChip(
                            label: vm.isCustomDuration ? '${vm.selectedDurationMinutes}' : null,
                            unit: vm.isCustomDuration ? 'min' : 'Custom',
                            icon: vm.isCustomDuration ? null : Icons.edit_outlined,
                            selected: vm.isCustomDuration,
                            dashedBorder: !vm.isCustomDuration,
                            onTap: () => _promptCustomDuration(context, vm),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              "If you don't check in after the timer ends, your primary contact will be notified.",
                              style: AppTextStyles.caption,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Notes
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.edit_note, color: AppColors.primary),
                          const SizedBox(width: AppSpacing.xs),
                          Text('Notes (Optional)', style: AppTextStyles.h2),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: vm.notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'E.g., Going for a run in Central Park. Wearing a blue jacket.',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Guardian summary
                _Card(
                  color: AppColors.surfaceContainerLow,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.location_on, color: AppColors.onPrimaryContainer, size: 20),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Live Location Sharing', style: AppTextStyles.labelBold),
                                const SizedBox(height: 2),
                                Text(
                                  'Your real-time location will be shared continuously while this session is active.',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: AppSpacing.lg),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.secondaryContainer,
                            child: Text(
                              vm.selectedGuardian?.initials ?? '?',
                              style: AppTextStyles.labelBold,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Notifying', style: AppTextStyles.caption),
                                Text(
                                  vm.selectedGuardian?.name ?? 'No contact available',
                                  style: AppTextStyles.labelBold,
                                ),
                              ],
                            ),
                          ),
                          if (vm.contacts.isNotEmpty)
                            TextButton(
                              onPressed: () => _pickGuardian(context, vm),
                              child: const Text('Change'),
                            ),
                        ],
                      ),
                      if (vm.contacts.isEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Add a trusted contact from the Contacts tab to notify someone automatically.',
                          style: AppTextStyles.caption.copyWith(color: AppColors.error),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // Fixed bottom CTA
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.marginMobile,
                  AppSpacing.md,
                  AppSpacing.marginMobile,
                  AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.background.withOpacity(0), AppColors.background],
                  ),
                ),
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: vm.isSubmitting ? null : () => _handleStart(context, vm),
                    icon: vm.isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                          )
                        : const Icon(Icons.security),
                    label: Text('Start Safety Session', style: AppTextStyles.h2.copyWith(color: AppColors.onPrimary)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final Color? color;

  const _Card({required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: child,
    );
  }
}

class _DurationChip extends StatelessWidget {
  final String? label;
  final String unit;
  final IconData? icon;
  final bool selected;
  final bool dashedBorder;
  final VoidCallback onTap;

  const _DurationChip({
    this.label,
    required this.unit,
    this.icon,
    required this.selected,
    this.dashedBorder = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryContainer.withOpacity(0.08) : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Icon(icon, color: selected ? AppColors.primary : AppColors.onSurfaceVariant)
              else
                Text(
                  label ?? '',
                  style: AppTextStyles.displayMd.copyWith(
                    fontSize: 26,
                    color: selected ? AppColors.primary : AppColors.onSurface,
                  ),
                ),
              Text(
                unit,
                style: AppTextStyles.labelBold.copyWith(
                  color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
