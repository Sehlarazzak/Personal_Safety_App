/// Represents the lifecycle of a Safety Timer & Check-In session.
///
/// Module 1 only needs this enum to drive the dashboard's status card and
/// navigation shell. The actual timer/GPS/notification behavior behind
/// each state is implemented in Modules 3 and 4.
enum SafetySessionStatus {
  /// No session has been started, or the last one finished cleanly.
  none,

  /// A session is currently counting down.
  active,

  /// The countdown reached the reminder threshold and is waiting for the
  /// user to confirm "I'm Safe" or "I Need Help".
  awaitingCheckIn,

  /// The user tapped "I'm Safe" before expiry.
  completedSafe,

  /// The user tapped "I Need Help", or the session expired unanswered.
  escalated,
}

extension SafetySessionStatusX on SafetySessionStatus {
  String get label {
    switch (this) {
      case SafetySessionStatus.none:
        return 'No active session';
      case SafetySessionStatus.active:
        return 'Session active';
      case SafetySessionStatus.awaitingCheckIn:
        return 'Check-in required';
      case SafetySessionStatus.completedSafe:
        return 'Marked safe';
      case SafetySessionStatus.escalated:
        return 'Emergency escalated';
    }
  }

  bool get isEmergency => this == SafetySessionStatus.escalated;
}
