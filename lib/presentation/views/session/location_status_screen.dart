import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/contact_launcher.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';

/// Shows the current session's last known GPS fix — coordinates, when it
/// was captured, and how stale it might be — plus manual "Refresh" and
/// "Open in Maps" actions.
///
/// Reads directly from the shared [SessionController] (same pattern as
/// `ActiveSessionScreen`) rather than owning its own copy of location
/// state, since the controller is already the single source of truth for
/// everything about the current session.
class LocationStatusScreen extends StatelessWidget {
  const LocationStatusScreen({super.key});

  String _formatAge(DateTime? updatedAt) {
    if (updatedAt == null) return 'Not yet captured';
    final age = DateTime.now().difference(updatedAt);
    if (age.inSeconds < 60) return 'Just now';
    if (age.inMinutes < 60) return '${age.inMinutes} min ago';
    return '${age.inHours} hr ago';
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SessionController>();
    final session = controller.session;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Location Status')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        session != null && session.hasLocation
                            ? Icons.location_on
                            : Icons.location_off,
                        size: 32,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (session != null && session.hasLocation) ...[
                      Text(
                        '${session.latitude!.toStringAsFixed(5)}, ${session.longitude!.toStringAsFixed(5)}',
                        style: AppTextStyles.h2,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Last updated ${_formatAge(session.locationUpdatedAt)}',
                        style: AppTextStyles.bodyMd,
                      ),
                    ] else ...[
                      Text('No location captured yet', style: AppTextStyles.h2, textAlign: TextAlign.center),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Start a safety session to begin sharing your location.',
                        style: AppTextStyles.bodyMd,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (controller.locationError != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        controller.locationError!,
                        style: AppTextStyles.caption.copyWith(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: controller.isFetchingLocation
                    ? null
                    : () => controller.refreshLocationNow(),
                icon: controller.isFetchingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(controller.isFetchingLocation ? 'Refreshing...' : 'Refresh Location'),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(AppA11y.minTouchTarget)),
              ),
              const SizedBox(height: AppSpacing.sm),
              ElevatedButton.icon(
                onPressed: (session != null && session.hasLocation)
                    ? () => _openInMaps(context, session.latitude!, session.longitude!)
                    : null,
                icon: const Icon(Icons.map_outlined),
                label: const Text('Open in Maps'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openInMaps(BuildContext context, double lat, double lng) async {
    final launcher = context.read<ContactLauncher>();
    try {
      await launcher.launchMaps(lat, lng);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Maps on this device.')),
        );
      }
    }
  }
}
