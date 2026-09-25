import 'package:geolocator/geolocator.dart';

/// Thrown when location can't be obtained (permission denied, service
/// disabled, etc.) so callers can show a friendly message instead of a
/// raw platform exception.
class LocationException implements Exception {
  final String message;
  const LocationException(this.message);

  @override
  String toString() => message;
}

/// A plain lat/lng snapshot, decoupled from the `geolocator` package's own
/// `Position` type so the rest of the app never has to import it directly.
class LocationSnapshot {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  const LocationSnapshot({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });
}

/// Abstraction over "however we get the device's location" so
/// `SessionController` never imports `geolocator` directly — the same
/// seam used for auth/contacts/sessions, so Module 6 can fake this in
/// tests without a real GPS fix.
abstract class LocationRepository {
  /// Requests permission if needed, then returns a single current fix.
  /// Throws [LocationException] if permission is denied or location
  /// services are off.
  Future<LocationSnapshot> getCurrentLocation();
}

/// `geolocator`-backed implementation.
class GeolocatorLocationRepository implements LocationRepository {
  @override
  Future<LocationSnapshot> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(
        'Location services are turned off. Enable them to share your location during a session.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationException(
          'Location permission was denied. Safety Guard needs it to share your location during a session.',
        );
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Location permission is permanently denied. Enable it from your device Settings to use this feature.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    return LocationSnapshot(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: DateTime.now(),
    );
  }
}
