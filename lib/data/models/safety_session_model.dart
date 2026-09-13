import 'safety_session_status.dart';

/// A single Safety Timer & Check-In session.
///
/// Created when the user taps "Start Safety Session", updated as it
/// counts down / gets checked into / escalates, and persisted so Module 5
/// can render it in Safety History.
class SafetySessionModel {
  final String id;
  final DateTime startTime;
  final int durationMinutes;
  final String? notes;
  final String? guardianContactId;
  final String? guardianContactName;
  final SafetySessionStatus status;

  /// Only set once the session leaves [SafetySessionStatus.active] /
  /// [awaitingCheckIn] — i.e. completed, escalated, or cancelled.
  final DateTime? endTime;

  const SafetySessionModel({
    required this.id,
    required this.startTime,
    required this.durationMinutes,
    this.notes,
    this.guardianContactId,
    this.guardianContactName,
    this.status = SafetySessionStatus.active,
    this.endTime,
  });

  DateTime get expiresAt => startTime.add(Duration(minutes: durationMinutes));

  Duration get remaining {
    final diff = expiresAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  SafetySessionModel copyWith({
    SafetySessionStatus? status,
    DateTime? endTime,
  }) {
    return SafetySessionModel(
      id: id,
      startTime: startTime,
      durationMinutes: durationMinutes,
      notes: notes,
      guardianContactId: guardianContactId,
      guardianContactName: guardianContactName,
      status: status ?? this.status,
      endTime: endTime ?? this.endTime,
    );
  }

  factory SafetySessionModel.fromMap(String id, Map<String, dynamic> map) {
    return SafetySessionModel(
      id: id,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTimeMs'] as int),
      durationMinutes: map['durationMinutes'] as int? ?? 0,
      notes: map['notes'] as String?,
      guardianContactId: map['guardianContactId'] as String?,
      guardianContactName: map['guardianContactName'] as String?,
      status: SafetySessionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SafetySessionStatus.none,
      ),
      endTime: map['endTimeMs'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['endTimeMs'] as int)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startTimeMs': startTime.millisecondsSinceEpoch,
      'durationMinutes': durationMinutes,
      'notes': notes,
      'guardianContactId': guardianContactId,
      'guardianContactName': guardianContactName,
      'status': status.name,
      'endTimeMs': endTime?.millisecondsSinceEpoch,
    };
  }
}
