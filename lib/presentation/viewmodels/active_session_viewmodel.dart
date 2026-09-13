import 'package:flutter/foundation.dart';
import '../../core/session/session_controller.dart';
import '../../data/models/safety_session_model.dart';
import '../../data/models/safety_session_status.dart';

/// Drives the Active Safety Session screen — mirrors
/// `active_safety_session/code.html`: countdown display, guardian/location
/// info cards, and the "I'm Safe" / "I Need Help" / "Cancel Session"
/// actions.
///
/// This is a thin View-facing wrapper around the shared [SessionController]
/// (see its doc comment for why session state lives above screen level).
/// It exists so `ActiveSessionScreen` depends on a normal ViewModel, not
/// directly on the app-wide controller.
class ActiveSessionViewModel extends ChangeNotifier {
  final SessionController sessionController;

  ActiveSessionViewModel({required this.sessionController}) {
    sessionController.addListener(_onSessionChanged);
  }

  void _onSessionChanged() => notifyListeners();

  SafetySessionModel? get session => sessionController.session;
  SafetySessionStatus get status => sessionController.status;
  bool get isAwaitingCheckIn => status == SafetySessionStatus.awaitingCheckIn;
  bool get hasFinished => session != null && !status.isOngoing;

  String get formattedRemaining {
    final remaining = sessionController.remaining;
    final minutes = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get statusChipLabel {
    switch (status) {
      case SafetySessionStatus.active:
        return 'Monitoring active';
      case SafetySessionStatus.awaitingCheckIn:
        return "Time's up — please check in";
      case SafetySessionStatus.completedSafe:
        return 'Marked safe';
      case SafetySessionStatus.escalated:
        return 'Contacts notified';
      case SafetySessionStatus.cancelled:
        return 'Session cancelled';
      case SafetySessionStatus.none:
        return 'No active session';
    }
  }

  String get guardianSummary {
    final name = session?.guardianContactName;
    return name == null ? 'No contact selected' : 'Live location shared with $name';
  }

  Future<void> markSafe() => sessionController.markSafe();

  Future<void> needHelp() => sessionController.escalate();

  Future<void> cancelSession() => sessionController.cancelSession();

  @override
  void dispose() {
    sessionController.removeListener(_onSessionChanged);
    super.dispose();
  }
}
