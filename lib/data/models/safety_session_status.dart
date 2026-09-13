/// Represents the lifecycle of a Safety Timer & Check-In session.
///
/// Module 1 introduced this enum to drive the dashboard's status card.
/// Module 3 gives it real teeth: [SafetySessionModel] carries one of
/// these values and [ActiveSessionViewModel] drives the transitions.
enum SafetySessionStatus {
  /// No session has been started, or the last one finished cleanly.
  none,

  /// A session is currently counting down.
  active,

  /// The countdown reached zero and is waiting for the user to confirm
  /// "I'm Safe" or "I Need Help" before auto-escalating.
  awaitingCheckIn,

  /// The user tapped "I'm Safe" before or at expiry.
  completedSafe,

  /// The user tapped "I Need Help", or the session expired unanswered.
  escalated,

  /// The user cancelled the session manually before it completed.
  cancelled,
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
      case SafetySessionStatus.cancelled:
        return 'Session cancelled';
    }
  }

  bool get isEmergency => this == SafetySessionStatus.escalated;

  bool get isOngoing =>
      this == SafetySessionStatus.active || this == SafetySessionStatus.awaitingCheckIn;
}
