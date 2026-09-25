import 'safety_session_status.dart';

/// A single Safety Timer & Check-In session.
///
/// Created when the user taps "Start Safety Session", updated as it
/// counts down / gets checked into / escalates, and persisted so Module 5
/// can render it in Safety History.
///
/// Module 4 adds [latitude]/[longitude]/[locationUpdatedAt] so the
/// session record carries the user's last known location — written
/// periodically while the session is ongoing, and used both by the
/// in-app Location Status screen and by the SMS dispatched to the
/// guardian contact on escalation.
class SafetySessionModel {
  final String id;
  final DateTime startTime;
  final int durationMinutes;
  final String? notes;
  final String? guardianContactId;
  final String? guardianContactName;
  final String? guardianPhoneNumber;
  final SafetySessionStatus status;

  /// Only set once the session leaves [SafetySessionStatus.active] /
  /// [awaitingCheckIn] — i.e. completed, escalated, or cancelled.
  final DateTime? endTime;

  final double? latitude;
  final double? longitude;
  final DateTime? locationUpdatedAt;

  const SafetySessionModel({
    required this.id,
    required this.startTime,
    required this.durationMinutes,
    this.notes,
    this.guardianContactId,
    this.guardianContactName,
    this.guardianPhoneNumber,
    this.status = SafetySessionStatus.active,
    this.endTime,
    this.latitude,
    this.longitude,
    this.locationUpdatedAt,
  });

  DateTime get expiresAt => startTime.add(Duration(minutes: durationMinutes));

  Duration get remaining {
    final diff = expiresAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get hasLocation => latitude != null && longitude != null;

  /// A plain Google Maps link for the last known location — used both in
  /// the escalation SMS body and the "Open in Maps" button on the
  /// Location Status screen.
  String? get mapsUrl =>
      hasLocation ? 'https://maps.google.com/?q=$latitude,$longitude' : null;

  SafetySessionModel copyWith({
    SafetySessionStatus? status,
    DateTime? endTime,
    double? latitude,
    double? longitude,
    DateTime? locationUpdatedAt,
  }) {
    return SafetySessionModel(
      id: id,
      startTime: startTime,
      durationMinutes: durationMinutes,
      notes: notes,
      guardianContactId: guardianContactId,
      guardianContactName: guardianContactName,
      guardianPhoneNumber: guardianPhoneNumber,
      status: status ?? this.status,
      endTime: endTime ?? this.endTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationUpdatedAt: locationUpdatedAt ?? this.locationUpdatedAt,
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
      guardianPhoneNumber: map['guardianPhoneNumber'] as String?,
      status: SafetySessionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SafetySessionStatus.none,
      ),
      endTime: map['endTimeMs'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['endTimeMs'] as int)
          : null,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      locationUpdatedAt: map['locationUpdatedAtMs'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['locationUpdatedAtMs'] as int)
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
      'guardianPhoneNumber': guardianPhoneNumber,
      'status': status.name,
      'endTimeMs': endTime?.millisecondsSinceEpoch,
      'latitude': latitude,
      'longitude': longitude,
      'locationUpdatedAtMs': locationUpdatedAt?.millisecondsSinceEpoch,
    };
  }
}
