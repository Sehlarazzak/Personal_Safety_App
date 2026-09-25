import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Fires on-device (local) notifications for two moments in the Safety
/// Timer lifecycle: when a session's countdown reaches zero and needs a
/// check-in, and when a session escalates.
///
/// This is NOT push notifications to a guardian's device — that requires
/// a server/Cloud Functions component to relay an FCM message, which is
/// out of scope for a client-only app (see README § "Module 4
/// Limitations"). What this gives the *user* is a real OS notification
/// even if Safety Guard is backgrounded when their timer expires.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channelId = 'safety_guard_sessions';
  static const _channelName = 'Safety Sessions';

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(settings);

    // Android 13+ requires a runtime notification permission request.
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  Future<void> showCheckInReminder() => _show(
        id: 1,
        title: 'Time to check in',
        body: "Your safety timer has ended. Tap to confirm you're safe.",
      );

  Future<void> showEscalationConfirmation({String? guardianName}) => _show(
        id: 2,
        title: 'Emergency contacts notified',
        body: guardianName != null
            ? 'We started an SMS to $guardianName with your location.'
            : 'An emergency alert was triggered for your session.',
      );

  Future<void> _show({required int id, required String title, required String body}) async {
    if (!_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Alerts about your active Safety Guard sessions',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(id, title, body, details);
  }
}
