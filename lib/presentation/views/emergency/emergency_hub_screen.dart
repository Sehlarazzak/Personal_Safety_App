import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/services/contact_launcher.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/safety_session_status.dart';
import '../../../data/models/trusted_contact_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/contacts_repository.dart';
import '../../widgets/app_emergency_button.dart';

/// A dedicated emergency hub, replacing the Module 3 stand-in where
/// tapping "Emergency Assistance" on the dashboard silently started and
/// immediately escalated a 1-minute session with no other options.
///
/// This screen gives three real, independent actions:
/// - A big SOS button that escalates the current/a new session and
///   dispatches an SMS (with location) to the primary contact.
/// - "Call Primary Contact" — opens the dialer directly, no session
///   needed, for when talking is faster than waiting on a text.
/// - "Call Emergency Services" — opens the dialer to a local emergency
///   number. This is NOT region-aware (see the note on-screen); it
///   defaults to 911 and the user should adjust for their country.
class EmergencyHubScreen extends StatefulWidget {
  const EmergencyHubScreen({super.key});

  @override
  State<EmergencyHubScreen> createState() => _EmergencyHubScreenState();
}

class _EmergencyHubScreenState extends State<EmergencyHubScreen> {
  List<TrustedContactModel> _contacts = [];
  bool _isLoadingContacts = true;
  bool _isTriggeringSos = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final userId = context.read<AuthRepository>().currentUser?.id ?? 'guest';
    final repo = context.read<ContactsRepository>();
    final list = await repo.watchContacts(userId).first;
    if (!mounted) return;
    setState(() {
      _contacts = list;
      _isLoadingContacts = false;
    });
  }

  TrustedContactModel? get _primaryContact {
    if (_contacts.isEmpty) return null;
    return _contacts.firstWhere(
      (c) => c.isPrimary,
      orElse: () => _contacts.first,
    );
  }

  Future<void> _triggerSos() async {
    final controller = context.read<SessionController>();
    final userId = context.read<AuthRepository>().currentUser?.id ?? 'guest';

    setState(() => _isTriggeringSos = true);

    if (!controller.hasOngoingSession) {
      await controller.startSession(
        userId: userId,
        durationMinutes: 1,
        guardian: _primaryContact,
      );
      await controller.escalate();
    } else if (controller.status != SafetySessionStatus.escalated) {
      await controller.escalate();
    }

    if (!mounted) return;
    setState(() => _isTriggeringSos = false);
    context.push(AppRoutes.activeSession);
  }

  Future<void> _callContact(TrustedContactModel? contact) async {
    if (contact == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a trusted contact first, from the Contacts tab.')),
      );
      return;
    }
    try {
      await context.read<ContactLauncher>().launchCall(contact.phoneNumber);
    } on LaunchException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _callEmergencyServices() async {
    // NOTE: 911 is the US/Canada emergency number. This is not
    // region-aware — a production release should detect locale/country
    // and use the correct local number (999 UK, 112 EU, 000 AU, etc.).
    try {
      await context.read<ContactLauncher>().launchCall('911');
    } on LaunchException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SessionController>();
    final primary = _primaryContact;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Emergency Assistance')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'If you are in immediate danger, call your local emergency services first.',
                style: AppTextStyles.bodyMd,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),

              // SOS button
              SizedBox(
                height: 160,
                child: ElevatedButton(
                  onPressed: _isTriggeringSos ? null : _triggerSos,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.onError,
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                  ),
                  child: _isTriggeringSos
                      ? const CircularProgressIndicator(color: AppColors.onError)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.sos, size: 48),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'SOS',
                              style: AppTextStyles.h1.copyWith(color: AppColors.onError),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                controller.hasOngoingSession
                    ? 'Tap to escalate your current session and alert your contact.'
                    : 'Tap to start an emergency alert with your location.',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Quick actions
              if (_isLoadingContacts)
                const Center(child: CircularProgressIndicator())
              else ...[
                AppEmergencyButton(
                  label: primary != null ? 'Call ${primary.name}' : 'Call Primary Contact',
                  icon: Icons.call,
                  onPressed: () => _callContact(primary),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              OutlinedButton.icon(
                onPressed: _callEmergencyServices,
                icon: const Icon(Icons.local_police_outlined),
                label: const Text('Call Emergency Services (911)'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(AppA11y.minTouchTarget),
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.locationStatus),
                icon: const Icon(Icons.location_on_outlined),
                label: const Text('View My Location'),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(AppA11y.minTouchTarget)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
