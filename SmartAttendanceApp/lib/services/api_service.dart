import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/api_error.dart';
import '../models/attendance_record.dart';
import '../models/create_user_models.dart';
import '../models/login_models.dart';
import '../models/user_list_item.dart';

typedef TokenGetter = Future<String?> Function();

class ApiService {
  ApiService(this._getToken, {http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.effectiveApiBaseUrl;

  final TokenGetter _getToken;
  final http.Client _client;
  final String _baseUrl;

  Uri _uri(String path) {
    final base = _baseUrl.endsWith('/') ? _baseUrl.substring(0, _baseUrl.length - 1) : _baseUrl;
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$p');
  }

  Future<Map<String, String>> _headers({bool jsonBody = true}) async {
    final token = await _getToken();
    return {
      if (jsonBody) 'Content-Type': 'application/json; charset=utf-8',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  String _extractMessage(String body, int status) {
    try {
      final map = jsonDecode(body);
      if (map is Map<String, dynamic>) {
        final m = map['message'] as String?;
        if (m != null && m.isNotEmpty) return m;
      }
    } catch (_) {
      /* use fallback */
    }
    if (body.isNotEmpty && body.length < 500) return body;
    return 'Request failed ($status)';
  }

  Future<void> _throwIfNotOk(http.Response r) async {
    if (r.statusCode >= 200 && r.statusCode < 300) return;
    throw ApiError(_extractMessage(r.body, r.statusCode), statusCode: r.statusCode);
  }

  Future<LoginResponse> login(LoginRequest request) async {
    final uri = _uri('/auth/login');
    final r = await _client.post(
      uri,
      headers: await _headers(),
      body: jsonEncode(request.toJson()),
    );
    await _throwIfNotOk(r);
    final map = jsonDecode(r.body) as Map<String, dynamic>;
    return LoginResponse.fromJson(map);
  }

  Future<List<UserListItem>> getUsers() async {
    final uri = _uri('/admin/users');
    final r = await _client.get(uri, headers: await _headers(jsonBody: false));
    await _throwIfNotOk(r);
    final list = jsonDecode(r.body) as List<dynamic>;
    return list
        .map((e) => UserListItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CreateUserResponse> createUser(CreateUserRequest request) async {
    final uri = _uri('/admin/create-user');
    final r = await _client.post(
      uri,
      headers: await _headers(),
      body: jsonEncode(request.toJson()),
    );
    await _throwIfNotOk(r);
    return CreateUserResponse.fromJson(
      jsonDecode(r.body) as Map<String, dynamic>,
    );
  }

  Future<CheckInResponse> checkIn(double latitude, double longitude) async {
    final uri = _uri('/attendance/check-in');
    final r = await _client.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({'latitude': latitude, 'longitude': longitude}),
    );
    await _throwIfNotOk(r);
    return CheckInResponse.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  Future<CheckOutResponse> checkOut(double latitude, double longitude) async {
    final uri = _uri('/attendance/check-out');
    final r = await _client.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({'latitude': latitude, 'longitude': longitude}),
    );
    await _throwIfNotOk(r);
    return CheckOutResponse.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  Future<List<AttendanceRecord>> getMyAttendance() async {
    final uri = _uri('/attendance/my-records');
    final r = await _client.get(uri, headers: await _headers(jsonBody: false));
    await _throwIfNotOk(r);
    final list = jsonDecode(r.body) as List<dynamic>;
    return list
        .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  void dispose() => _client.close();
}
