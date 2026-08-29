import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
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
/// The two primary actions are stubbed with snackbars for now — Module 3
/// wires "Start Safety Session" into the real timer flow, and Module 4
/// wires "Emergency Assistance" into the dispatch flow.
class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: const _HomeDashboardView(),
    );
  }
}

class _HomeDashboardView extends StatelessWidget {
  const _HomeDashboardView();

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
              label: 'Start Safety Session',
              leadingIcon: Icons.play_arrow,
              pillShaped: true,
              height: 64,
              onPressed: () {
                // TODO(Module 3): navigate to the "Start Safety Session" flow.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Safety Timer & Check-In arrives in Module 3.')),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppEmergencyButton(
              label: 'Emergency Assistance',
              onPressed: () {
                // TODO(Module 4): navigate to the Emergency Hub / dispatch flow.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Emergency dispatch arrives in Module 4.')),
                );
              },
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
                    onTrailingTap: () {
                      // TODO(Module 2): navigate to Add/Edit Contact screen.
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...vm.primaryContacts.map(
                    (contact) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: TrustedContactTile(
                        contact: contact,
                        onCall: () {
                          // TODO(Module 4): trigger the platform dialer.
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
