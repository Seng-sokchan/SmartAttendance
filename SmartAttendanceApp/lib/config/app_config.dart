import 'package:flutter/foundation.dart' show kIsWeb;

/// Base URL for the API **without** a trailing slash.
///
/// - **Web (browser):** `http://localhost:PORT/api` (not `10.0.2.2`).
/// - Android emulator: `http://10.0.2.2:PORT/api` to reach the host machine.
/// - Physical device: your PC's LAN IP.
///
/// Override: `flutter run --dart-define=API_BASE_URL=http://localhost:5291/api`
class AppConfig {
  AppConfig._();

  static const String _fromEnv = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const String _androidEmulatorDefault = 'http://10.0.2.2:5291/api';
  static const String _webDefault = 'http://localhost:5291/api';

  /// Effective base URL (web vs mobile defaults + dart-define).
  static String get effectiveApiBaseUrl {
    if (_fromEnv.isNotEmpty) return _fromEnv;
    if (kIsWeb) return _webDefault;
    return _androidEmulatorDefault;
  }

  @Deprecated('Use effectiveApiBaseUrl')
  static String get apiBaseUrl => effectiveApiBaseUrl;

  static const double officeLatitude = 11.5564;
  static const double officeLongitude = 104.9282;
  static const double officeRadiusMeters = 100;

  /// Shown on the map marker / card (adjust to your site name).
  static const String officeMapLabel = 'Office';

  /// Local time: check-out button enabled at or after this hour (24h).
  static const int checkOutEarliestHour = 17;
}
