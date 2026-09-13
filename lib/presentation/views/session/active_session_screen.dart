import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/safety_session_status.dart';
import '../../viewmodels/active_session_viewmodel.dart';
import '../../widgets/app_emergency_button.dart';
import '../../widgets/app_primary_button.dart';

/// Active Safety Session screen — mirrors `active_safety_session/code.html`:
/// a "Monitoring active" status chip, a pulsing countdown ring, location +
/// guardian info cards, and the "I'm Safe" / "I Need Help" / "Cancel
/// Session" actions.
///
/// Reads its state from the shared [SessionController] via
/// [ActiveSessionViewModel] so the countdown keeps running correctly even
/// if the user briefly navigates elsewhere and back.
class ActiveSessionScreen extends StatelessWidget {
  const ActiveSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ActiveSessionViewModel(
        sessionController: context.read<SessionController>(),
      ),
      child: const _ActiveSessionView(),
    );
  }
}

class _ActiveSessionView extends StatelessWidget {
  const _ActiveSessionView();

  Future<void> _confirmAndRun(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required Future<void> Function() action,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Not yet'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel, style: TextStyle(color: confirmColor)),
          ),
        ],
      ),
    );
    if (confirmed == true) await action();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ActiveSessionViewModel>();

    // Once the session reaches a terminal state, briefly show it, then
    // return to the dashboard and free up the controller for a new session.
    if (vm.hasFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted) return;
        await Future.delayed(const Duration(seconds: 2));
        if (!context.mounted) return;
        vm.sessionController.clearFinishedSession();
        context.go(AppRoutes.home);
      });
    }

    final isEmergency = vm.status == SafetySessionStatus.escalated;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Safety Guard')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.marginMobile,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            children: [
              // Status chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: isEmergency ? AppColors.errorContainer : AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isEmergency ? Icons.emergency : Icons.shield,
                      size: 16,
                      color: isEmergency ? AppColors.onErrorContainer : AppColors.onPrimaryContainer,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      vm.statusChipLabel,
                      style: AppTextStyles.labelBold.copyWith(
                        color: isEmergency ? AppColors.onErrorContainer : AppColors.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(vm.guardianSummary, style: AppTextStyles.caption),
              const SizedBox(height: AppSpacing.md),

              // Countdown ring
              _PulsingCountdownRing(
                label: vm.formattedRemaining,
                sublabel: vm.isAwaitingCheckIn ? 'Please check in' : 'Remaining',
                emphasize: vm.isAwaitingCheckIn || isEmergency,
              ),
              const SizedBox(height: AppSpacing.md),

              // Info cards
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.location_on_outlined,
                      title: 'Location',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Live location sharing', style: AppTextStyles.bodyMd, maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: AppSpacing.xs),
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: const Icon(Icons.my_location, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.contacts_outlined,
                      title: 'Guardian',
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.tertiaryContainer,
                            child: Text(
                              _initialsFor(vm.session?.guardianContactName),
                              style: AppTextStyles.h2.copyWith(color: AppColors.onTertiaryContainer, fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vm.session?.guardianContactName ?? 'None',
                                  style: AppTextStyles.bodyMd,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text('Notified', style: AppTextStyles.caption),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Primary actions
              AppPrimaryButton(
                label: "I'm Safe",
                leadingIcon: Icons.check_circle,
                height: 64,
                onPressed: vm.hasFinished
                    ? null
                    : () => _confirmAndRun(
                          context,
                          title: 'Confirm you are safe',
                          message: 'This will end your safety session.',
                          confirmLabel: "I'm Safe",
                          confirmColor: AppColors.primary,
                          action: vm.markSafe,
                        ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppEmergencyButton(
                label: 'I Need Help',
                filled: true,
                onPressed: vm.hasFinished
                    ? null
                    : () => _confirmAndRun(
                          context,
                          title: 'Request emergency help?',
                          message: 'Your guardian contact will be notified immediately with your location.',
                          confirmLabel: 'I Need Help',
                          confirmColor: AppColors.error,
                          action: vm.needHelp,
                        ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (!vm.hasFinished)
                TextButton(
                  onPressed: () => _confirmAndRun(
                    context,
                    title: 'Cancel session?',
                    message: 'Your guardian contact will not be notified.',
                    confirmLabel: 'Cancel Session',
                    confirmColor: AppColors.error,
                    action: vm.cancelSession,
                  ),
                  child: const Text('Cancel Session'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple two-letter initials for the guardian avatar, without depending
/// on the `characters` package for grapheme-safe substring logic — trusted
/// contact names are plain ASCII in this app's expected use case.
String _initialsFor(String? name) {
  if (name == null || name.trim().isEmpty) return '?';
  final parts = name.trim().split(RegExp(r'\s+'));
  final first = parts.first.isNotEmpty ? parts.first[0] : '';
  final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
  final initials = (first + last);
  return initials.isEmpty ? '?' : initials.toUpperCase();
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _InfoCard({required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
              const SizedBox(width: AppSpacing.xs),
              Text(title, style: AppTextStyles.labelBold),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          child,
        ],
      ),
    );
  }
}

/// A gently pulsing ring around the countdown text — a lightweight nod to
/// the mockup's animated rings without needing a heavier animation stack.
class _PulsingCountdownRing extends StatefulWidget {
  final String label;
  final String sublabel;
  final bool emphasize;

  const _PulsingCountdownRing({
    required this.label,
    required this.sublabel,
    this.emphasize = false,
  });

  @override
  State<_PulsingCountdownRing> createState() => _PulsingCountdownRingState();
}

class _PulsingCountdownRingState extends State<_PulsingCountdownRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ringColor = widget.emphasize ? AppColors.error : AppColors.primary;

    return SizedBox(
      width: 240,
      height: 240,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              _pulseCircle(ringColor, t),
              _pulseCircle(ringColor, (t + 0.5) % 1.0),
              Container(
                width: 176,
                height: 176,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.outlineVariant),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 16)],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.label,
                      style: AppTextStyles.displayLg.copyWith(fontSize: 40, color: ringColor),
                    ),
                    Text(
                      widget.sublabel.toUpperCase(),
                      style: AppTextStyles.labelBold.copyWith(
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _pulseCircle(Color color, double t) {
    final scale = 0.7 + (t * 0.3);
    final opacity = (1 - t).clamp(0.0, 1.0) * 0.4;
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 4),
          ),
        ),
      ),
    );
  }
}
