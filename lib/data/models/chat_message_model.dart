class ChatMessageModel {
  final String id;
  final String sessionId;
  final String content;
  final bool isUser;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.sessionId,
    required this.content,
    required this.isUser,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      content: json['content'] as String,
      isUser: json['is_user'] as bool? ?? true,
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'content': content,
      'is_user': isUser,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create insert map (without id, let DB generate it)
  Map<String, dynamic> toInsertJson() {
    return {
      'session_id': sessionId,
      'content': content,
      'is_user': isUser,
    };
  }
}
