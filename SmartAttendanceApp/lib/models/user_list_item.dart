class UserListItem {
  UserListItem({
    required this.id,
    required this.username,
    required this.role,
    required this.createdAt,
  });

  final int id;
  final String username;
  final String role;
  final DateTime createdAt;

  factory UserListItem.fromJson(Map<String, dynamic> json) {
    return UserListItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '',
      role: json['role'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}
