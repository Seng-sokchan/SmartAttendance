import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _kToken = 'jwt_token';
  static const _kUsername = 'username';
  static const _kRole = 'role';

  final FlutterSecureStorage _storage;

  Future<void> saveSession({
    required String token,
    required String username,
    required String role,
  }) async {
    await _storage.write(key: _kToken, value: token);
    await _storage.write(key: _kUsername, value: username);
    await _storage.write(key: _kRole, value: role);
  }

  Future<String?> readToken() => _storage.read(key: _kToken);

  Future<String?> readUsername() => _storage.read(key: _kUsername);

  Future<String?> readRole() => _storage.read(key: _kRole);

  Future<void> clear() async {
    await _storage.delete(key: _kToken);
    await _storage.delete(key: _kUsername);
    await _storage.delete(key: _kRole);
  }
}
