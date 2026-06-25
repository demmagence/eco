import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:eco/data/models/chat_message_model.dart';
import 'package:eco/data/models/chat_session_model.dart';
import 'package:eco/data/repositories/groq_repository.dart';
import 'package:eco/data/repositories/chat_repository.dart';
import 'package:eco/core/constants/app_strings.dart';
import 'package:uuid/uuid.dart';
import 'package:eco/data/models/chatbot_args.dart';
import 'package:eco/data/models/scan_result_model.dart';

class ChatbotViewModel extends ChangeNotifier {
  final GroqRepository _groqRepository;
  final ChatRepository _chatRepository;
  final _uuid = const Uuid();

  List<ChatMessageModel> _messages = [];
  ChatSessionModel? _session;
  bool _isTyping = false;
  String? _errorMessage;
  // Tracks whether we are loading an existing session (to prevent
  // the view from accidentally calling initNewSession at the same time).
  bool _isLoadingExisting = false;
  ScanResultModel? _scanContext;
  Uint8List? _localImageBytes;

  ChatbotViewModel({
    GroqRepository? groqRepository,
    ChatRepository? chatRepository,
    ChatbotArgs? args,
  })  : _groqRepository = groqRepository ?? GroqRepository(),
        _chatRepository = chatRepository ?? ChatRepository() {
    if (args != null) {
      if (args.sessionId != null) {
        _isLoadingExisting = true;
        _loadExistingSession(args.sessionId!);
      } else if (args.scanContext != null) {
        _localImageBytes = args.localImageBytes;
        _isLoadingExisting = true;
        initSessionWithScanContext(args.scanContext!, initialMessage: args.initialMessage);
      }
    }
  }

  // Getters
  List<ChatMessageModel> get messages => _messages;
  bool get isTyping => _isTyping;
  String? get errorMessage => _errorMessage;
  ChatSessionModel? get session => _session;
  /// True while an existing session is being loaded from the database.
  bool get isLoadingExisting => _isLoadingExisting;
  ScanResultModel? get scanContext => _scanContext;
  Uint8List? get localImageBytes => _localImageBytes;

  /// Initialize a new chat session
  Future<void> initNewSession() async {
    try {
      _session = await _chatRepository.createSession();
      _messages = [];
      _groqRepository.resetChat();

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

  /// Initialize session with a scan result as context
  Future<void> initSessionWithScanContext(ScanResultModel scan, {String? initialMessage}) async {
    _scanContext = scan;
    try {
      _session = await _chatRepository.createSession();
      _messages = [];
      
      // Initialize the chatbot with the scan context
      _groqRepository.startChatWithScanContext(scan);

      // Add the context greeting from Eco Assistant to the message list and save it
      final greetingText = 'Halo! Saya Eco Assistant 🌿 Saya telah melihat hasil analisis foto lingkungan Anda di ${scan.locationName ?? "lokasi Anda"}. '
          'Kondisi yang terdeteksi: ${scan.environmentCondition.length > 80 ? "${scan.environmentCondition.substring(0, 80)}..." : scan.environmentCondition}\n\n'
          'Apakah ada yang ingin Anda diskusikan atau tanyakan tentang kondisi tersebut atau saran penanganannya?';
      
      final welcomeMsg = ChatMessageModel(
        id: _uuid.v4(),
        sessionId: _session!.id,
        content: greetingText,
        isUser: false,
        createdAt: DateTime.now(),
      );
      _messages.add(welcomeMsg);
      await _chatRepository.saveMessage(welcomeMsg);

      _isLoadingExisting = false;
      notifyListeners();

      // If there's an initial message, send it now
      if (initialMessage != null && initialMessage.trim().isNotEmpty) {
        await sendMessage(initialMessage);
      }
    } catch (e) {
      _isLoadingExisting = false;
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
      final response = await _groqRepository.sendChatMessage(text);

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
