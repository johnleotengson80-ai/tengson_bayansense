/// Result of a successful login (CON-03): who you are, your role, and your token.
class Session {
  const Session({required this.id, required this.role, required this.token});

  final int id;

  /// 'resident' | 'personnel' | 'admin'
  final String role;
  final String token;

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        id: json['id'] as int,
        role: json['role'] as String,
        token: json['token'] as String,
      );
}
