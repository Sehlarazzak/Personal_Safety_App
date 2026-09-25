import 'package:url_launcher/url_launcher.dart';

/// Thrown when the platform can't open the requested app (dialer, SMS
/// composer, Maps) — e.g. no SMS app installed on a tablet/emulator.
class LaunchException implements Exception {
  final String message;
  const LaunchException(this.message);

  @override
  String toString() => message;
}

/// Wraps `url_launcher` calls for the three platform actions this app
/// needs: opening the dialer, opening the SMS composer with a prefilled
/// message, and opening a location in Google Maps.
///
/// This is deliberately a thin, stateless service rather than a
/// repository (there's no data to read/write) — but it's still injected
/// via `provider` like the repositories, so Module 6 can substitute a
/// fake in widget tests without actually launching apps.
class ContactLauncher {
  Future<void> launchCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: _sanitizePhone(phoneNumber));
    final launched = await launchUrl(uri);
    if (!launched) {
      throw const LaunchException('Could not open the phone dialer.');
    }
  }

  /// Opens the SMS composer addressed to [phoneNumber] with [message]
  /// pre-filled. The user still has to tap Send — true silent, automatic
  /// SMS sending would require native platform-channel code and the
  /// sensitive SEND_SMS permission, which is out of scope here (see
  /// README § "Module 4 Limitations").
  Future<void> launchSms(String phoneNumber, String message) async {
    final uri = Uri(
      scheme: 'sms',
      path: _sanitizePhone(phoneNumber),
      queryParameters: {'body': message},
    );
    final launched = await launchUrl(uri);
    if (!launched) {
      throw const LaunchException('Could not open the messaging app.');
    }
  }

  Future<void> launchMaps(double latitude, double longitude) async {
    final uri = Uri.parse('https://maps.google.com/?q=$latitude,$longitude');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      throw const LaunchException('Could not open Maps.');
    }
  }

  String _sanitizePhone(String phoneNumber) =>
      phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
}
