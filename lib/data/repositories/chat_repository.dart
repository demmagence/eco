import 'package:eco/data/models/chat_message_model.dart';
import 'package:eco/data/models/chat_session_model.dart';
import 'package:eco/data/services/supabase_service.dart';

class ChatRepository {
  /// Create a new chat session
  Future<ChatSessionModel> createSession({String? title}) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    final response = await SupabaseService.chatSessions
        .insert({
          'user_id': userId,
          'title': title ?? 'Chat Baru',
        })
        .select()
        .single();

    return ChatSessionModel.fromJson(response);
  }

  /// Get all chat sessions for current user
  Future<List<ChatSessionModel>> getChatSessions() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return [];

    final response = await SupabaseService.chatSessions
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);

    return (response as List)
        .map((json) => ChatSessionModel.fromJson(json))
        .toList();
  }

  /// Get messages for a session
  Future<List<ChatMessageModel>> getMessages(String sessionId) async {
    final response = await SupabaseService.chatMessages
        .select()
        .eq('session_id', sessionId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => ChatMessageModel.fromJson(json))
        .toList();
  }

  /// Save a message
  Future<ChatMessageModel> saveMessage(ChatMessageModel message) async {
    final response = await SupabaseService.chatMessages
        .insert(message.toInsertJson())
        .select()
        .single();

    // Update session's updated_at
    await SupabaseService.chatSessions
        .update({'updated_at': DateTime.now().toIso8601String()})
        .eq('id', message.sessionId);

    return ChatMessageModel.fromJson(response);
  }

  /// Update session title
  Future<void> updateSessionTitle(String sessionId, String title) async {
    await SupabaseService.chatSessions
        .update({'title': title})
        .eq('id', sessionId);
  }

  /// Delete a chat session (cascades to messages)
  Future<void> deleteSession(String sessionId) async {
    await SupabaseService.chatSessions.delete().eq('id', sessionId);
  }

  /// Get chat session count
  Future<int> getSessionCount() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return 0;

    final response = await SupabaseService.chatSessions
        .select('id')
        .eq('user_id', userId);

    return (response as List).length;
  }
}
