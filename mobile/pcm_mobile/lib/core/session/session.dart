class SessionUser {
  SessionUser({
    required this.memberId,
    required this.fullName,
    required this.email,
    required this.walletBalance,
  });

  final int memberId;
  final String fullName;
  final String email;
  final double walletBalance;

  bool get isAdmin => email.toLowerCase() == 'luc@gmail.com';

  SessionUser copyWith({
    int? memberId,
    String? fullName,
    String? email,
    double? walletBalance,
  }) {
    return SessionUser(
      memberId: memberId ?? this.memberId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      walletBalance: walletBalance ?? this.walletBalance,
    );
  }

  static SessionUser fromMeJson(Map<String, dynamic> json) {
    return SessionUser(
      memberId: (json['id'] ?? 0) as int,
      fullName: (json['fullName'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      walletBalance: (json['walletBalance'] ?? 0).toDouble(),
    );
  }
}


