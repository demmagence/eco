class ChatSessionModel {
  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastMessage;

  const ChatSessionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
  });

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String? ?? 'Chat Baru',
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      lastMessage: json['last_message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create insert map (without id, let DB generate it)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'title': title,
    };
  }

  ChatSessionModel copyWith({
    String? title,
    DateTime? updatedAt,
    String? lastMessage,
  }) {
    return ChatSessionModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}
