import 'package:eco/data/services/groq_service.dart';
import 'package:eco/data/models/scan_result_model.dart';

/// Repository for the Eco Assistant chatbot, backed by Groq.
///
/// Exposes the same chat surface the chatbot previously consumed from
/// [GeminiRepository], so the ViewModel only had to swap the dependency.
class GroqRepository {
  final GroqService _groqService;

  GroqRepository({GroqService? groqService})
      : _groqService = groqService ?? GroqService();

  Future<String> sendChatMessage(String message) =>
      _groqService.sendChatMessage(message);

  void startChat() => _groqService.startChat();

  void startChatWithScanContext(ScanResultModel scan) =>
      _groqService.startChatWithScanContext(scan);

  void resetChat() => _groqService.resetChat();
}
