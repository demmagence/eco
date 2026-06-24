import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:eco/core/constants/api_constants.dart';
import 'package:eco/data/models/scan_result_model.dart';

class GeminiService {
  late final GenerativeModel _model;
  ChatSession? _chatSession;

  GeminiService() {
    _model = GenerativeModel(
      model: ApiConstants.geminiModel,
      apiKey: ApiConstants.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 2048,
      ),
    );
  }

  /// Analyze an image for environmental assessment
  Future<String> analyzeImage({
    required Uint8List imageBytes,
    String? locationContext,
  }) async {
    final locationInfo =
        locationContext != null ? 'Lokasi: $locationContext. ' : '';

    final prompt = '''
$locationInfo
Kamu adalah ahli lingkungan Indonesia yang berpengalaman. Analisis foto ini dan berikan respons dalam format JSON berikut:

{
  "kondisi_lingkungan": "Deskripsi detail kondisi lingkungan yang terlihat di foto, termasuk jenis sampah atau polusi yang terdeteksi.",
  "prediksi_dampak": "Analisis dampak yang sudah terjadi dan prediksi dampak yang akan datang jika kondisi ini dibiarkan. Jelaskan kondisi sebelum dan sesudah serta potensi dampak masa depan.",
  "saran_penanganan": "Langkah-langkah konkret yang bisa dilakukan untuk mengatasi masalah lingkungan yang terlihat di foto.",
  "instansi": [
    {
      "name": "Nama instansi yang bisa dihubungi",
      "phone": "Nomor telepon",
      "description": "Deskripsi singkat fungsi instansi"
    }
  ]
}

Pastikan analisis menyeluruh dan saran yang actionable. Berikan minimal 3 instansi terkait di Indonesia.
''';

    final content = Content.multi([
      TextPart(prompt),
      DataPart('image/jpeg', imageBytes),
    ]);

    final response = await _model.generateContent([content]);
    return response.text ?? '';
  }

  /// Generate environmental news summary based on location
  Future<String> generateNews({String? location}) async {
    final locationInfo = location ?? 'Indonesia';
    final prompt = '''
Berikan 3 ringkasan berita lingkungan terkini di $locationInfo dalam format JSON:
[
  {
    "judul": "Judul berita",
    "ringkasan": "Ringkasan singkat berita (2-3 kalimat)",
    "kategori": "sampah/polusi/iklim/konservasi"
  }
]
Berikan berita yang relevan dan terkini.
''';

    final content = Content.text(prompt);
    final response = await _model.generateContent([content]);
    return response.text ?? '[]';
  }

  /// Generate daily eco tip
  Future<String> generateDailyTip() async {
    final prompt = '''
Berikan satu tips harian ramah lingkungan yang praktis dan bisa langsung dilakukan hari ini.
Format JSON:
{
  "tips": "Tips singkat dan actionable",
  "detail": "Penjelasan lebih lanjut mengapa tips ini penting dan dampaknya",
  "emoji": "Emoji yang relevan"
}
''';

    final content = Content.text(prompt);
    final response = await _model.generateContent([content]);
    return response.text ?? '';
  }

  /// Start or continue a chat session
  ChatSession startChat() {
    _chatSession = _model.startChat(
      history: [
        Content.text(
          'Kamu adalah Eco Assistant, asisten AI ramah lingkungan berbahasa Indonesia. '
          'Kamu ahli dalam topik lingkungan, sampah, daur ulang, polusi, perubahan iklim, '
          'dan cara-cara praktis untuk menjaga lingkungan. Jawab dengan ramah, informatif, '
          'dan berikan saran yang actionable. Gunakan emoji yang relevan untuk membuat '
          'percakapan lebih menarik.',
        ),
        Content.model([
          TextPart(
            'Halo! Saya Eco Assistant 🌿 Saya siap membantu Anda dengan pertanyaan '
            'seputar lingkungan, sampah, daur ulang, dan cara menjaga bumi kita. '
            'Silakan tanya apa saja!',
          ),
        ]),
      ],
    );
    return _chatSession!;
  }

  /// Start chat session with a scan context
  ChatSession startChatWithScanContext(ScanResultModel scan) {
    final contextPrompt = '''
Kamu adalah Eco Assistant, asisten AI ramah lingkungan berbahasa Indonesia. 
Pengguna baru saja mengambil gambar dan menganalisisnya dengan AI. Berikut adalah data hasil analisis gambar tersebut:
- Lokasi: ${scan.locationName ?? 'Tidak diketahui'}
- Kondisi Lingkungan: ${scan.environmentCondition}
- Prediksi Dampak: ${scan.impactPrediction}
- Saran Penanganan: ${scan.suggestions}

Kamu harus menjawab pertanyaan pengguna berikutnya dengan mempertimbangkan konteks gambar dan analisis di atas. Jawablah dengan ramah, informatif, dan berikan saran yang actionable dengan emoji yang relevan.
''';

    _chatSession = _model.startChat(
      history: [
        Content.text(contextPrompt),
        Content.model([
          TextPart(
            'Halo! Saya Eco Assistant 🌿 Saya telah melihat hasil analisis foto lingkungan Anda di ${scan.locationName ?? "lokasi Anda"}. '
            'Kondisi yang terdeteksi: ${scan.environmentCondition.length > 80 ? "${scan.environmentCondition.substring(0, 80)}..." : scan.environmentCondition}\n\n'
            'Apakah ada yang ingin Anda diskusikan atau tanyakan tentang kondisi tersebut atau saran penanganannya?',
          ),
        ]),
      ],
    );
    return _chatSession!;
  }

  /// Send a message in the current chat session
  Future<String> sendChatMessage(String message) async {
    _chatSession ??= startChat();
    final content = Content.text(message);
    final response = await _chatSession!.sendMessage(content);
    return response.text ?? '';
  }

  /// Reset chat session
  void resetChat() {
    _chatSession = null;
  }
}
