import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eco/core/constants/api_constants.dart';
import 'package:eco/data/models/scan_result_model.dart';

/// Thin wrapper over Groq's OpenAI-compatible Chat Completions API, used for
/// the Eco Assistant chatbot.
///
/// Unlike Gemini's SDK there is no stateful chat session, so we keep the
/// conversation history ourselves as a list of OpenAI-style {role, content}
/// messages and resend it on every request.
class GroqService {
  final http.Client _client;
  final List<Map<String, String>> _history = [];

  GroqService({http.Client? client}) : _client = client ?? http.Client();

  static const String _systemPersona =
      'Kamu adalah Eco Assistant, asisten AI ramah lingkungan berbahasa Indonesia. '
      'Kamu ahli dalam topik lingkungan, sampah, daur ulang, polusi, perubahan iklim, '
      'dan cara-cara praktis untuk menjaga lingkungan. Jawab dengan ramah, informatif, '
      'dan berikan saran yang actionable. Gunakan emoji yang relevan untuk membuat '
      'percakapan lebih menarik.';

  /// Start (or restart) a plain chat session seeded with the Eco persona.
  void startChat() {
    _history
      ..clear()
      ..add({'role': 'system', 'content': _systemPersona});
  }

  /// Start a chat session seeded with a scan analysis as context, so the
  /// assistant can answer follow-up questions about the photo.
  void startChatWithScanContext(ScanResultModel scan) {
    final contextPrompt = '''
Kamu adalah Eco Assistant, asisten AI ramah lingkungan berbahasa Indonesia.
Pengguna baru saja mengambil gambar dan menganalisisnya dengan AI. Berikut adalah data hasil analisis gambar tersebut:
- Lokasi: ${scan.locationName ?? 'Tidak diketahui'}
- Kondisi Lingkungan: ${scan.environmentCondition}
- Prediksi Dampak: ${scan.impactPrediction}
- Saran Penanganan: ${scan.suggestions}

Kamu harus menjawab pertanyaan pengguna berikutnya dengan mempertimbangkan konteks gambar dan analisis di atas. Jawablah dengan ramah, informatif, dan berikan saran yang actionable dengan emoji yang relevan.
''';

    _history
      ..clear()
      ..add({'role': 'system', 'content': contextPrompt});
  }

  /// Send a message and return the assistant reply, keeping conversation
  /// history so the model has full context on the next turn.
  Future<String> sendChatMessage(String message) async {
    if (_history.isEmpty) startChat();

    _history.add({'role': 'user', 'content': message});

    final uri = Uri.parse(
      '${ApiConstants.groqBaseUrl}${ApiConstants.groqChatEndpoint}',
    );

    http.Response response;
    try {
      response = await _client.post(
        uri,
        headers: {
          'Authorization': 'Bearer ${ApiConstants.groqApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': ApiConstants.groqModel,
          'messages': _history,
          'temperature': 0.7,
          'max_tokens': 2048,
        }),
      );
    } catch (e) {
      // Network failure — drop the unanswered user turn so a retry is clean.
      _history.removeLast();
      rethrow;
    }

    if (response.statusCode != 200) {
      _history.removeLast();
      throw Exception(
        'Groq API error ${response.statusCode}: ${response.body}',
      );
    }

    // Decode as UTF-8 explicitly so Indonesian text and emoji survive.
    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final choices = data['choices'] as List?;
    final content = (choices != null && choices.isNotEmpty)
        ? (choices.first['message']?['content'] as String?)?.trim() ?? ''
        : '';

    _history.add({'role': 'assistant', 'content': content});
    return content;
  }

  /// Clear the conversation history.
  void resetChat() {
    _history.clear();
  }
}
