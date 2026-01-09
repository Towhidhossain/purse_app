class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarImagePath,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String displayName;
  final String? avatarImagePath; // Path to stored avatar image
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'avatarImagePath': avatarImagePath,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String,
        avatarImagePath: json['avatarImagePath'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  UserProfile copyWith({
    String? displayName,
    String? avatarImagePath,
    bool clearAvatar = false,
  }) {
    return UserProfile(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      avatarImagePath: clearAvatar ? null : (avatarImagePath ?? this.avatarImagePath),
      createdAt: createdAt,
    );
  }
}
