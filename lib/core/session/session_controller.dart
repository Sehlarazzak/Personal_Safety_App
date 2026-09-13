import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/safety_session_model.dart';
import '../../data/models/safety_session_status.dart';
import '../../data/models/trusted_contact_model.dart';
import '../../data/repositories/session_repository.dart';

/// The single source of truth for "is there a Safety Timer & Check-In
/// session running right now, and what state is it in."
///
/// This lives above the screen level (provided once at the app root, see
/// `app.dart`) rather than inside a single screen's ViewModel, because
/// three different screens all need to agree on it at once:
/// - `HomeDashboardScreen` shows the live status card
/// - `StartSessionScreen` creates a new session
/// - `ActiveSessionScreen` drives the countdown and check-in actions
///
/// `StartSessionViewModel` and `ActiveSessionViewModel` are thin,
/// screen-specific wrappers around this controller — it plays the role of
/// a shared domain model/service in the MVVM sense, not a View.
class SessionController extends ChangeNotifier {
  final SessionRepository _repository;
  static const _uuid = Uuid();

  SessionController({required SessionRepository repository}) : _repository = repository;

  SafetySessionModel? _session;
  Timer? _ticker;
  Duration _remaining = Duration.zero;
  String? _userId;

  SafetySessionModel? get session => _session;
  Duration get remaining => _remaining;
  SafetySessionStatus get status => _session?.status ?? SafetySessionStatus.none;
  bool get hasOngoingSession => status.isOngoing;

  /// Starts a new session, persists it, and begins the 1-second ticker.
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
      status: SafetySessionStatus.active,
    );

    _userId = userId;
    _session = session;
    _remaining = session.remaining;

    await _repository.createSession(userId, session);
    _startTicker();
    notifyListeners();
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
    }

    notifyListeners();
  }

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

  /// User tapped "I Need Help" (or a future background job calls this on
  /// unanswered expiry) — escalates to the guardian contact.
  ///
  /// TODO(Module 4): trigger the real dispatch — SMS/push notification to
  /// the guardian contact and live location sharing. For now this only
  /// updates local + persisted session state so the UI/flow is complete.
  Future<void> escalate() async {
    if (_session == null) return;
    _ticker?.cancel();
    _session = _session!.copyWith(
      status: SafetySessionStatus.escalated,
      endTime: DateTime.now(),
    );
    await _persist();
    notifyListeners();
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
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    final userId = _userId;
    final session = _session;
    if (userId == null || session == null) return;
    await _repository.updateSession(userId, session);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
