class UserModel {
  final String id;
  final String nis;
  final String email;
  final String displayName;
  final String? username;
  final String? photoUrl;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.nis,
    required this.email,
    required this.displayName,
    this.username,
    this.photoUrl,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      nis: json['nis'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      username: json['username'] as String?,
      photoUrl: json['photo_url'] as String?,
      createdAt: _parseDate(json['created_at']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nis': nis,
      'email': email,
      'display_name': displayName,
      'username': username,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? nis,
    String? email,
    String? displayName,
    String? username,
    String? photoUrl,
    bool clearPhotoUrl = false,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      nis: nis ?? this.nis,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      photoUrl: clearPhotoUrl ? null : (photoUrl ?? this.photoUrl),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Display string: if display name is empty, show username or NIS
  String get displayLabel {
    if (displayName.isNotEmpty) return displayName;
    if (username != null && username!.isNotEmpty) return '@$username';
    return 'NIS: $nis';
  }

  /// Formatted @username
  String? get formattedUsername {
    if (username == null || username!.isEmpty) return null;
    return '@$username';
  }
}
