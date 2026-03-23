import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../models/api_error.dart';
import '../models/attendance_record.dart';
import '../services/api_service.dart';
import '../services/office_location.dart';

class AttendanceProvider extends ChangeNotifier {
  AttendanceProvider(this._api);

  final ApiService _api;

  List<AttendanceRecord> _records = [];
  List<AttendanceRecord> get records => List.unmodifiable(_records);

  bool _loading = false;
  bool get loading => _loading;

  bool _checkInBusy = false;
  bool _checkOutBusy = false;

  bool get checkInBusy => _checkInBusy;
  bool get checkOutBusy => _checkOutBusy;

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  AttendanceRecord? get todayRecord {
    final t = _today;
    for (final r in _records) {
      if (r.date.year == t.year &&
          r.date.month == t.month &&
          r.date.day == t.day) {
        return r;
      }
    }
    return null;
  }

  bool get _isAfterFivePm =>
      DateTime.now().hour >= AppConfig.checkOutEarliestHour;

  bool get canPressCheckIn {
    if (_loading || _checkInBusy) return false;
    final tr = todayRecord;
    if (tr?.checkInTime != null) return false;
    return true;
  }

  bool get canPressCheckOut {
    if (_loading || _checkOutBusy) return false;
    if (!_isAfterFivePm) return false;
    final tr = todayRecord;
    if (tr == null || tr.checkInTime == null) return false;
    if (tr.checkOutTime != null) return false;
    return true;
  }

  /// Shown under the Check In button when it is disabled (helps visibility vs. greyed-out only).
  String? get checkInDisabledHint {
    if (canPressCheckIn) return null;
    if (_loading) return 'Loading attendance…';
    if (_checkInBusy) return 'Check-in in progress…';
    if (todayRecord?.checkInTime != null) {
      return 'You already checked in today.';
    }
    return null;
  }

  /// Shown under the Check Out button when it is disabled.
  String? get checkOutDisabledHint {
    if (canPressCheckOut) return null;
    if (_loading) return 'Loading attendance…';
    if (_checkOutBusy) return 'Check-out in progress…';
    if (!_isAfterFivePm) {
      return 'Check-out is available from ${AppConfig.checkOutEarliestHour}:00.';
    }
    final tr = todayRecord;
    if (tr == null || tr.checkInTime == null) {
      return 'Check in first before checking out.';
    }
    if (tr.checkOutTime != null) {
      return 'You already checked out today.';
    }
    return null;
  }

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    try {
      _records = await _api.getMyAttendance();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Returns null on success, or an error message for the UI (snackbar).
  Future<String?> checkIn() async {
    if (!canPressCheckIn) return null;

    _checkInBusy = true;
    notifyListeners();
    try {
      final (lat, lng) = await OfficeLocationService.requireOfficeCoordinates();
      await _api.checkIn(lat, lng);
      await refresh();
      return null;
    } on OutsideOfficeException catch (e) {
      return e.message;
    } on ApiError catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    } finally {
      _checkInBusy = false;
      notifyListeners();
    }
  }

  /// Returns null on success, or an error message for the UI (snackbar).
  Future<String?> checkOut() async {
    if (!_isAfterFivePm) {
      return 'Too early to check out';
    }
    if (_loading || _checkOutBusy) return null;
    final tr = todayRecord;
    if (tr?.checkInTime == null) {
      return 'Too early to check out';
    }
    if (tr?.checkOutTime != null) {
      return null;
    }

    _checkOutBusy = true;
    notifyListeners();
    try {
      final (lat, lng) = await OfficeLocationService.requireOfficeCoordinates();
      await _api.checkOut(lat, lng);
      await refresh();
      return null;
    } on OutsideOfficeException catch (e) {
      return e.message;
    } on ApiError catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    } finally {
      _checkOutBusy = false;
      notifyListeners();
    }
  }
}
