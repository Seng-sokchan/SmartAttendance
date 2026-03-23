import 'package:geolocator/geolocator.dart';

import '../config/app_config.dart';

class OfficeLocationResult {
  OfficeLocationResult({
    required this.position,
    required this.distanceMeters,
    required this.withinRadius,
  });

  final Position position;
  final double distanceMeters;
  final bool withinRadius;
}

/// Thrown when the user is outside the allowed office radius.
class OutsideOfficeException implements Exception {
  OutsideOfficeException(this.message);
  final String message;

  @override
  String toString() => message;
}

class OfficeLocationService {
  OfficeLocationService._();

  static Future<void> ensureServiceEnabled() async {
    var enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      enabled = await Geolocator.openLocationSettings();
    }
    if (!enabled) {
      throw Exception('Location services are disabled.');
    }
  }

  static Future<void> ensurePermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied. Enable it in settings.');
    }
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied.');
    }
  }

  /// Current GPS position and whether it is within [AppConfig.officeRadiusMeters].
  static Future<OfficeLocationResult> getVerifiedPosition() async {
    await ensureServiceEnabled();
    await ensurePermission();

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      AppConfig.officeLatitude,
      AppConfig.officeLongitude,
    );

    final within = distance <= AppConfig.officeRadiusMeters;
    return OfficeLocationResult(
      position: position,
      distanceMeters: distance,
      withinRadius: within,
    );
  }

  /// Returns coordinates only if within office radius; otherwise throws [OutsideOfficeException].
  static Future<(double lat, double lng)> requireOfficeCoordinates() async {
    final result = await getVerifiedPosition();
    if (!result.withinRadius) {
      throw OutsideOfficeException('You are outside office area');
    }
    return (result.position.latitude, result.position.longitude);
  }
}
