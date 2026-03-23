class AttendanceRecord {
  AttendanceRecord({
    required this.id,
    required this.userId,
    required this.checkInTime,
    required this.checkOutTime,
    required this.date,
    required this.latitude,
    required this.longitude,
  });

  final int id;
  final int userId;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  /// API sends `date` as `yyyy-MM-dd` (DateOnly).
  final DateTime date;
  final double latitude;
  final double longitude;

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    final dateStr = json['date'] as String? ?? '';
    final dateOnly = DateTime.tryParse(dateStr) ??
        DateTime.tryParse('${dateStr}T00:00:00') ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

    DateTime? parseDt(String? s) =>
        s == null || s.isEmpty ? null : DateTime.tryParse(s);

    return AttendanceRecord(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      checkInTime: parseDt(json['checkInTime'] as String?),
      checkOutTime: parseDt(json['checkOutTime'] as String?),
      date: DateTime(dateOnly.year, dateOnly.month, dateOnly.day),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
    );
  }
}

class CheckInResponse {
  CheckInResponse({required this.attendanceId, this.message});

  final int attendanceId;
  final String? message;

  factory CheckInResponse.fromJson(Map<String, dynamic> json) {
    return CheckInResponse(
      attendanceId: (json['attendanceId'] as num?)?.toInt() ?? 0,
      message: json['message'] as String?,
    );
  }
}

class CheckOutResponse {
  CheckOutResponse({this.message});

  final String? message;

  factory CheckOutResponse.fromJson(Map<String, dynamic> json) {
    return CheckOutResponse(message: json['message'] as String?);
  }
}
