import 'package:flutter/material.dart';
import 'package:eco/data/models/scan_result_model.dart';
import 'package:eco/data/models/chat_session_model.dart';
import 'package:eco/data/repositories/scan_repository.dart';
import 'package:eco/data/repositories/chat_repository.dart';

class HistoryViewModel extends ChangeNotifier {
  final ScanRepository _scanRepository;
  final ChatRepository _chatRepository;

  List<ScanResultModel> _scanHistory = [];
  List<ChatSessionModel> _chatSessions = [];
  bool _isLoading = true;
  String? _errorMessage;

  HistoryViewModel({
    ScanRepository? scanRepository,
    ChatRepository? chatRepository,
  })  : _scanRepository = scanRepository ?? ScanRepository(),
        _chatRepository = chatRepository ?? ChatRepository();

  // Getters
  List<ScanResultModel> get scanHistory => _scanHistory;
  List<ChatSessionModel> get chatSessions => _chatSessions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load all history
  Future<void> loadHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _scanRepository.getScanHistory(),
        _chatRepository.getChatSessions(),
      ]);

      _scanHistory = results[0] as List<ScanResultModel>;
      _chatSessions = results[1] as List<ChatSessionModel>;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a scan
  Future<void> deleteScan(String id) async {
    try {
      await _scanRepository.deleteScan(id);
      _scanHistory.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Delete a chat session
  Future<void> deleteChatSession(String id) async {
    try {
      await _chatRepository.deleteSession(id);
      _chatSessions.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Refresh
  Future<void> refresh() async {
    await loadHistory();
  }
}
