class LoginRequest {
  LoginRequest({required this.username, required this.password});

  final String username;
  final String password;

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
      };
}

class LoginResponse {
  LoginResponse({
    required this.token,
    required this.username,
    required this.role,
    required this.expiresAtUtc,
  });

  final String token;
  final String username;
  final String role;
  final DateTime expiresAtUtc;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String? ?? '',
      username: json['username'] as String? ?? '',
      role: json['role'] as String? ?? '',
      expiresAtUtc: DateTime.tryParse(json['expiresAtUtc'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}
