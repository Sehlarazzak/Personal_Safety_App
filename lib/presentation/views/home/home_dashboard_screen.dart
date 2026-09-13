import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../data/models/safety_session_status.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/contacts_repository.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../widgets/app_emergency_button.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/safety_status_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/trusted_contact_tile.dart';

/// Home Dashboard tab — mirrors `home_dashboard/code.html`: safety-status
/// card, the "Start Safety Session" hero CTA, the reserved-red "Emergency
/// Assistance" shortcut, and a Trusted Contacts summary.
///
/// "Start Safety Session" now pushes into the real Module 3 flow. The
/// "Emergency Assistance" shortcut stays stubbed until Module 4 builds the
/// dedicated dispatch hub — tapping it just jumps straight into an
/// escalated session as a stand-in for that flow.
class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeViewModel(
        authRepository: context.read<AuthRepository>(),
        contactsRepository: context.read<ContactsRepository>(),
        sessionController: context.read<SessionController>(),
      ),
      child: const _HomeDashboardView(),
    );
  }
}

class _HomeDashboardView extends StatelessWidget {
  const _HomeDashboardView();

  Future<void> _handleEmergencyTap(BuildContext context, HomeViewModel vm) async {
    if (vm.sessionStatus.isOngoing) {
      // Already mid-session — jump straight to it rather than starting a
      // second, conflicting one.
      context.push(AppRoutes.activeSession);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Request emergency help?'),
        content: const Text(
          'Your primary contact will be notified immediately with your location. '
          'A full emergency dispatch experience arrives in Module 4 — for now '
          'this starts an escalated session right away.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('I Need Help', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final guardian = vm.primaryContacts.isNotEmpty ? vm.primaryContacts.first : null;
    await vm.sessionController.startSession(
      userId: vm.currentUser.id,
      durationMinutes: 1,
      guardian: guardian,
    );
    await vm.sessionController.escalate();
    if (context.mounted) context.push(AppRoutes.activeSession);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return RefreshIndicator(
      onRefresh: vm.refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.marginMobile,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SafetyStatusCard(status: vm.sessionStatus, subtitle: vm.sessionSubtitle),
            const SizedBox(height: AppSpacing.lg),
            AppPrimaryButton(
              label: vm.sessionStatus.isOngoing ? 'View Active Session' : 'Start Safety Session',
              leadingIcon: vm.sessionStatus.isOngoing ? Icons.visibility : Icons.play_arrow,
              pillShaped: true,
              height: 64,
              onPressed: () => context.push(
                vm.sessionStatus.isOngoing ? AppRoutes.activeSession : AppRoutes.startSession,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppEmergencyButton(
              label: 'Emergency Assistance',
              onPressed: () => _handleEmergencyTap(context, vm),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeader(
                    title: 'Trusted Contacts',
                    trailingIcon: Icons.add,
                    trailingTooltip: 'Add Contact',
                    onTrailingTap: () => context.push(AppRoutes.addContact),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (vm.contacts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Text(
                        'No trusted contacts yet — add one so someone can be notified during a session.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  else
                    ...(vm.primaryContacts.isNotEmpty ? vm.primaryContacts : vm.contacts.take(1)).map(
                      (contact) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: TrustedContactTile(
                          contact: contact,
                          onCall: () {
                            // TODO(Module 4): launch the platform dialer (url_launcher tel: scheme).
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
