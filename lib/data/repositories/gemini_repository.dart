import 'dart:typed_data';
import 'package:eco/data/services/gemini_service.dart';

class GeminiRepository {
  final GeminiService _geminiService;

  GeminiRepository({GeminiService? geminiService})
      : _geminiService = geminiService ?? GeminiService();

  Future<String> analyzeImage({
    required Uint8List imageBytes,
    String? locationContext,
  }) async {
    return _geminiService.analyzeImage(
      imageBytes: imageBytes,
      locationContext: locationContext,
    );
  }

  Future<String> generateNews({String? location}) async {
    return _geminiService.generateNews(location: location);
  }

  Future<String> generateDailyTip() async {
    return _geminiService.generateDailyTip();
  }

  Future<String> sendChatMessage(String message) async {
    return _geminiService.sendChatMessage(message);
  }

  void resetChat() {
    _geminiService.resetChat();
  }
}
