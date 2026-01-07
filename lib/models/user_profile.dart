class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.avatarHue,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String displayName;
  final double avatarHue; // 0-360 hue for consistent color
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'avatarHue': avatarHue,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String,
        avatarHue: (json['avatarHue'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  UserProfile copyWith({
    String? displayName,
    double? avatarHue,
  }) {
    return UserProfile(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      avatarHue: avatarHue ?? this.avatarHue,
      createdAt: createdAt,
    );
  }
}
