import 'package:flutter/material.dart';
import 'package:eco/data/models/chat_message_model.dart';
import 'package:eco/data/models/chat_session_model.dart';
import 'package:eco/data/repositories/gemini_repository.dart';
import 'package:eco/data/repositories/chat_repository.dart';
import 'package:eco/core/constants/app_strings.dart';
import 'package:uuid/uuid.dart';

class ChatbotViewModel extends ChangeNotifier {
  final GeminiRepository _geminiRepository;
  final ChatRepository _chatRepository;
  final _uuid = const Uuid();

  List<ChatMessageModel> _messages = [];
  ChatSessionModel? _session;
  bool _isTyping = false;
  String? _errorMessage;
  // Tracks whether we are loading an existing session (to prevent
  // the view from accidentally calling initNewSession at the same time).
  bool _isLoadingExisting = false;

  ChatbotViewModel({
    GeminiRepository? geminiRepository,
    ChatRepository? chatRepository,
    String? sessionId,
  })  : _geminiRepository = geminiRepository ?? GeminiRepository(),
        _chatRepository = chatRepository ?? ChatRepository() {
    if (sessionId != null) {
      _isLoadingExisting = true;
      _loadExistingSession(sessionId);
    }
  }

  // Getters
  List<ChatMessageModel> get messages => _messages;
  bool get isTyping => _isTyping;
  String? get errorMessage => _errorMessage;
  ChatSessionModel? get session => _session;
  /// True while an existing session is being loaded from the database.
  bool get isLoadingExisting => _isLoadingExisting;

  /// Initialize a new chat session
  Future<void> initNewSession() async {
    try {
      _session = await _chatRepository.createSession();
      _messages = [];
      _geminiRepository.resetChat();

      // Add welcome message
      final welcomeMsg = ChatMessageModel(
        id: _uuid.v4(),
        sessionId: _session!.id,
        content: AppStrings.chatbotWelcome,
        isUser: false,
        createdAt: DateTime.now(),
      );
      _messages.add(welcomeMsg);
      await _chatRepository.saveMessage(welcomeMsg);

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Load existing session
  Future<void> _loadExistingSession(String sessionId) async {
    try {
      _session = ChatSessionModel(
        id: sessionId,
        userId: '',
        title: 'Session',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _messages = await _chatRepository.getMessages(sessionId);
      _isLoadingExisting = false;
      notifyListeners();
    } catch (e) {
      _isLoadingExisting = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Send a message
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Ensure session exists
    if (_session == null) {
      await initNewSession();
    }

    // Add user message
    final userMsg = ChatMessageModel(
      id: _uuid.v4(),
      sessionId: _session!.id,
      content: text,
      isUser: true,
      createdAt: DateTime.now(),
    );
    _messages.add(userMsg);
    _isTyping = true;
    _errorMessage = null;
    notifyListeners();

    // Save user message
    try {
      await _chatRepository.saveMessage(userMsg);
    } catch (_) {}

    // Get AI response
    try {
      final response = await _geminiRepository.sendChatMessage(text);

      final aiMsg = ChatMessageModel(
        id: _uuid.v4(),
        sessionId: _session!.id,
        content: response,
        isUser: false,
        createdAt: DateTime.now(),
      );
      _messages.add(aiMsg);

      // Save AI message
      await _chatRepository.saveMessage(aiMsg);

      // Update session title from first user message
      if (_messages.where((m) => m.isUser).length == 1) {
        final title =
            text.length > 50 ? '${text.substring(0, 50)}...' : text;
        await _chatRepository.updateSessionTitle(_session!.id, title);
      }

      _isTyping = false;
      notifyListeners();
    } catch (e) {
      _isTyping = false;
      _errorMessage = 'Gagal mendapatkan respons: $e';
      notifyListeners();
    }
  }
}
