import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/safety_session_model.dart';
import '../../data/models/safety_session_status.dart';
import '../../data/models/trusted_contact_model.dart';
import '../../data/repositories/location_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../services/contact_launcher.dart';
import '../services/notification_service.dart';

/// The single source of truth for "is there a Safety Timer & Check-In
/// session running right now, and what state is it in."
///
/// This lives above the screen level (provided once at the app root, see
/// `app.dart`) rather than inside a single screen's ViewModel, because
/// several screens all need to agree on it at once:
/// - `HomeDashboardScreen` shows the live status card
/// - `StartSessionScreen` creates a new session
/// - `ActiveSessionScreen` drives the countdown and check-in actions
/// - `LocationStatusScreen` (Module 4) shows the last known fix
/// - `EmergencyHubScreen` (Module 4) can trigger an immediate escalation
///
/// `StartSessionViewModel` and `ActiveSessionViewModel` are thin,
/// screen-specific wrappers around this controller — it plays the role of
/// a shared domain model/service in the MVVM sense, not a View.
///
/// Module 4 adds: periodic GPS location capture while a session is
/// ongoing, and a real dispatch action on escalation — opening a prefilled
/// SMS (with a Maps link) to the guardian contact, plus a local
/// notification confirming it. See README § "Module 4 Limitations" for
/// why this is an SMS the user sends, not a silent push to the guardian's
/// device.
class SessionController extends ChangeNotifier {
  final SessionRepository _sessionRepository;
  final LocationRepository _locationRepository;
  final ContactLauncher _contactLauncher;
  final NotificationService _notificationService;
  static const _uuid = Uuid();

  SessionController({
    required SessionRepository sessionRepository,
    required LocationRepository locationRepository,
    required ContactLauncher contactLauncher,
    required NotificationService notificationService,
  })  : _sessionRepository = sessionRepository,
        _locationRepository = locationRepository,
        _contactLauncher = contactLauncher,
        _notificationService = notificationService;

  SafetySessionModel? _session;
  Timer? _ticker;
  Duration _remaining = Duration.zero;
  String? _userId;
  String? _locationError;
  bool _isFetchingLocation = false;

  /// Location is refreshed roughly this often while a session runs.
  static const _locationRefreshInterval = Duration(seconds: 30);
  int _ticksSinceLastLocationFetch = 0;

  SafetySessionModel? get session => _session;
  Duration get remaining => _remaining;
  SafetySessionStatus get status => _session?.status ?? SafetySessionStatus.none;
  bool get hasOngoingSession => status.isOngoing;

  /// Set when the last location fetch failed (e.g. permission denied) so
  /// the UI can surface it without the whole session failing.
  String? get locationError => _locationError;
  bool get isFetchingLocation => _isFetchingLocation;

  /// Starts a new session, persists it, begins the 1-second ticker, and
  /// captures an initial location fix (best-effort — a failure here
  /// doesn't block starting the session).
  Future<void> startSession({
    required String userId,
    required int durationMinutes,
    String? notes,
    TrustedContactModel? guardian,
  }) async {
    final session = SafetySessionModel(
      id: _uuid.v4(),
      startTime: DateTime.now(),
      durationMinutes: durationMinutes,
      notes: (notes == null || notes.trim().isEmpty) ? null : notes.trim(),
      guardianContactId: guardian?.id,
      guardianContactName: guardian?.name,
      guardianPhoneNumber: guardian?.phoneNumber,
      status: SafetySessionStatus.active,
    );

    _userId = userId;
    _session = session;
    _remaining = session.remaining;
    _locationError = null;
    _ticksSinceLastLocationFetch = 0;

    await _sessionRepository.createSession(userId, session);
    _startTicker();
    notifyListeners();

    // Best-effort initial fix — don't block session start on GPS.
    unawaited(_refreshLocation());
  }

  void _startTicker() {
    _ticker?.cancel();
    _tick();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final current = _session;
    if (current == null) return;

    _remaining = current.remaining;

    // Countdown hit zero: move to "awaiting check-in" rather than silently
    // auto-escalating, so the user gets one last chance to confirm safety.
    if (_remaining == Duration.zero && current.status == SafetySessionStatus.active) {
      _session = current.copyWith(status: SafetySessionStatus.awaitingCheckIn);
      unawaited(_persist());
      unawaited(_notificationService.showCheckInReminder());
    }

    // Periodic location refresh while the session is still ongoing.
    if (current.status.isOngoing) {
      _ticksSinceLastLocationFetch++;
      if (_ticksSinceLastLocationFetch >= _locationRefreshInterval.inSeconds) {
        _ticksSinceLastLocationFetch = 0;
        unawaited(_refreshLocation());
      }
    }

    notifyListeners();
  }

  Future<void> _refreshLocation() async {
    if (_session == null || _isFetchingLocation) return;
    _isFetchingLocation = true;
    notifyListeners();

    try {
      final fix = await _locationRepository.getCurrentLocation();
      _locationError = null;
      if (_session != null) {
        _session = _session!.copyWith(
          latitude: fix.latitude,
          longitude: fix.longitude,
          locationUpdatedAt: fix.timestamp,
        );
        await _persist();
      }
    } on LocationException catch (e) {
      _locationError = e.message;
    } catch (_) {
      _locationError = 'Could not get your current location.';
    } finally {
      _isFetchingLocation = false;
      notifyListeners();
    }
  }

  /// Manually triggers a location refresh — used by the "Refresh" button
  /// on the Location Status screen.
  Future<void> refreshLocationNow() => _refreshLocation();

  /// User confirmed they're safe — stops the ticker and closes the session.
  Future<void> markSafe() async {
    if (_session == null) return;
    _ticker?.cancel();
    _session = _session!.copyWith(
      status: SafetySessionStatus.completedSafe,
      endTime: DateTime.now(),
    );
    await _persist();
    notifyListeners();
  }

  /// User tapped "I Need Help" (or the Emergency Hub's SOS button) —
  /// escalates the session: captures one last location fix, opens a
  /// prefilled SMS to the guardian contact with a Maps link, and shows a
  /// local confirmation notification.
  Future<void> escalate() async {
    if (_session == null) return;
    _ticker?.cancel();

    // Best-effort final location fix before composing the alert — if this
    // fails we still escalate using whatever location (if any) is already
    // on the session.
    await _refreshLocation();

    _session = _session!.copyWith(
      status: SafetySessionStatus.escalated,
      endTime: DateTime.now(),
    );
    await _persist();
    notifyListeners();

    await _dispatchToGuardian(_session!);
    await _notificationService.showEscalationConfirmation(
      guardianName: _session!.guardianContactName,
    );
  }

  Future<void> _dispatchToGuardian(SafetySessionModel session) async {
    final phone = session.guardianPhoneNumber;
    if (phone == null || phone.isEmpty) return;

    final locationLine = session.hasLocation
        ? 'My last known location: ${session.mapsUrl}'
        : "I couldn't get a precise location, but I need help.";

    final message =
        "This is an automated Safety Guard alert: I may need help and didn't check in on time. $locationLine";

    try {
      await _contactLauncher.launchSms(phone, message);
    } catch (_) {
      // If the SMS composer can't be opened (e.g. no SMS app on this
      // device/emulator), the session is still correctly marked escalated
      // above — the UI's own error handling for launch failures covers
      // surfacing this to the user when they retry from the Emergency Hub.
    }
  }

  /// User cancelled the session manually before it ran out.
  Future<void> cancelSession() async {
    if (_session == null) return;
    _ticker?.cancel();
    _session = _session!.copyWith(
      status: SafetySessionStatus.cancelled,
      endTime: DateTime.now(),
    );
    await _persist();
    notifyListeners();
  }

  /// Clears a finished session from local state (e.g. after the dashboard
  /// has shown the "Marked safe" confirmation for a moment) so a new one
  /// can be started. Does nothing while a session is still ongoing.
  void clearFinishedSession() {
    if (_session != null && !_session!.status.isOngoing) {
      _session = null;
      _remaining = Duration.zero;
      _locationError = null;
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    final userId = _userId;
    final session = _session;
    if (userId == null || session == null) return;
    await _sessionRepository.updateSession(userId, session);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
