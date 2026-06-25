import 'dart:convert';
import 'package:eco/data/models/chat_message_model.dart';
import 'package:eco/data/models/chat_session_model.dart';
import 'package:eco/data/services/api_service.dart';

class ChatRepository {
  /// Create a new chat session
  Future<ChatSessionModel> createSession({String? title}) async {
    final response = await ApiService.post('/chat/sessions', {
      'title': title ?? 'Chat Baru',
    });

    final data = ApiService.decodeResponse(response);
    return _sessionFromJson(data);
  }

  /// Get all chat sessions for current user
  Future<List<ChatSessionModel>> getChatSessions() async {
    final response = await ApiService.get('/chat/sessions');
    final list = jsonDecode(utf8.decode(response.bodyBytes)) as List;
    return list.map((json) => _sessionFromJson(json as Map<String, dynamic>)).toList();
  }

  /// Get messages for a session
  Future<List<ChatMessageModel>> getMessages(String sessionId) async {
    final response = await ApiService.get('/chat/sessions/$sessionId/messages');
    final list = jsonDecode(utf8.decode(response.bodyBytes)) as List;
    return list.map((json) => _messageFromJson(json as Map<String, dynamic>)).toList();
  }

  /// Save a message
  Future<ChatMessageModel> saveMessage(ChatMessageModel message) async {
    final response = await ApiService.post('/chat/messages', {
      'session_id': message.sessionId,
      'content': message.content,
      'is_user': message.isUser,
    });

    final data = ApiService.decodeResponse(response);
    return _messageFromJson(data);
  }

  /// Update session title
  Future<void> updateSessionTitle(String sessionId, String title) async {
    await ApiService.put('/chat/sessions/$sessionId', {'title': title});
  }

  /// Delete a chat session (cascades to messages)
  Future<void> deleteSession(String sessionId) async {
    await ApiService.delete('/chat/sessions/$sessionId');
  }

  /// Get chat session count
  Future<int> getSessionCount() async {
    final response = await ApiService.get('/chat/sessions/count');
    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return (data['count'] as num?)?.toInt() ?? 0;
  }

  // ── Private Helpers ──────────────────────────────────────────────────

  static ChatSessionModel _sessionFromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String? ?? 'Chat Baru',
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      lastMessage: json['last_message'] as String?,
    );
  }

  static ChatMessageModel _messageFromJson(Map<String, dynamic> json) {
    // MySQL TINYINT is returned as int, convert to bool
    final isUser = json['is_user'];
    final isUserBool = isUser is bool ? isUser : (isUser == 1 || isUser == true);
    return ChatMessageModel(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      content: json['content'] as String,
      isUser: isUserBool,
      createdAt: _parseDate(json['created_at']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
