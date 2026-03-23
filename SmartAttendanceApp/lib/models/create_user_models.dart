class CreateUserRequest {
  CreateUserRequest({
    required this.username,
    required this.password,
    required this.role,
  });

  final String username;
  final String password;
  final String role;

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'role': role,
      };
}

class CreateUserResponse {
  CreateUserResponse({
    required this.userId,
    required this.username,
    required this.role,
  });

  final int userId;
  final String username;
  final String role;

  factory CreateUserResponse.fromJson(Map<String, dynamic> json) {
    return CreateUserResponse(
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }
}
