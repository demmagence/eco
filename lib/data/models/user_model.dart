class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      displayName: json['display_name'] as String? ?? 'User',
      photoUrl: json['photo_url'] as String?,
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
