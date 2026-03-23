import 'package:flutter/foundation.dart';

import '../models/login_models.dart';
import '../services/api_service.dart';
import '../services/token_storage.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({TokenStorage? storage})
      : _storage = storage ?? TokenStorage();

  final TokenStorage _storage;
  ApiService? _api;

  void bindApi(ApiService api) => _api = api;

  bool _initialized = false;
  bool get initialized => _initialized;

  String? _token;
  String? _username;
  String? _role;

  String? get token => _token;
  String? get username => _username;
  String? get role => _role;

  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  bool get isAdmin => (_role ?? '').toLowerCase() == 'admin';

  Future<void> restoreSession() async {
    _token = await _storage.readToken();
    _username = await _storage.readUsername();
    _role = await _storage.readRole();
    _initialized = true;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    final api = _api;
    if (api == null) throw StateError('ApiService not bound');

    final res = await api.login(
      LoginRequest(username: username, password: password),
    );

    _token = res.token;
    _username = res.username;
    _role = res.role;

    await _storage.saveSession(
      token: res.token,
      username: res.username,
      role: res.role,
    );
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.clear();
    _token = null;
    _username = null;
    _role = null;
    notifyListeners();
  }
}
