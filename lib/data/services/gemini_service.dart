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
    String scanMode = 'multiple',
  }) async {
    final locationInfo =
        locationContext != null ? 'Lokasi: $locationContext. ' : '';

    final prompt = scanMode == 'single' ? '''
$locationInfo
Kamu adalah ahli lingkungan hidup Indonesia yang berpengalaman dan bertindak sebagai Eco-Educator di lingkungan sekolah.
Analisis foto sampah ini (skala kecil/sedikit/spesifik) dan berikan respons dalam format JSON berikut:

{
  "cara_buang": "Penjelasan detail dan praktis tentang cara membuang sampah yang ada di dalam foto dengan benar agar aman dan sesuai aturan sanitasi.",
  "materi_edukasi": "Materi singkat/edukatif yang dirancang khusus untuk guru agar dapat diajarkan kepada siswa mengenai dampak sampah jenis ini di lingkungan sekolah.",
  "pengelompokan": "Klasifikasikan sampah di foto secara spesifik (misal: organik, anorganik, B3, kertas, plastik, kaca) beserta penjelasannya.",
  "daur_ulang": "Petunjuk praktis atau ide kreatif daur ulang (upcycling) yang dapat dilakukan oleh siswa untuk mendaur ulang sampah jenis ini."
}

Jawab dalam Bahasa Indonesia yang edukatif, ramah, dan mudah dipahami siswa sekolah.
''' : '''
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
            'Kondisi yang terdeteksi: ${(() { final ec = scan.environmentCondition ?? scan.correctDisposal ?? "kondisi lingkungan"; return ec.length > 80 ? "${ec.substring(0, 80)}..." : ec; })()}\n\n'
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

  /// Generate water quality analysis for a location
  Future<String> generateWaterQuality({String? location}) async {
    final locationInfo = location ?? 'Indonesia';
    final prompt = '''
Berikan analisis kualitas air di wilayah $locationInfo dalam format JSON:
{
  "status": "Bersih/Sedang/Tercemar",
  "cleanliness_level": 75,
  "description": "Deskripsi singkat kondisi kualitas air"
}
Berikan nilai cleanliness_level dari 0-100 (100 = sangat bersih).
Jawab hanya dengan JSON, tanpa penjelasan tambahan.
''';

    final content = Content.text(prompt);
    final response = await _model.generateContent([content]);
    return response.text ?? '{}';
  }

  /// Generate waste type analysis for a location
  Future<String> generateWasteAnalysis({String? location}) async {
    final locationInfo = location ?? 'Indonesia';
    final prompt = '''
Berikan analisis jenis sampah dominan di wilayah $locationInfo dalam format JSON:
{
  "dominant_type": "Plastik",
  "percentage": 45,
  "types": [
    {"name": "Plastik", "percentage": 45, "icon": "🥤"},
    {"name": "Organik", "percentage": 30, "icon": "🍂"},
    {"name": "Anorganik", "percentage": 15, "icon": "🔩"},
    {"name": "Elektronik", "percentage": 10, "icon": "📱"}
  ]
}
Jawab hanya dengan JSON, tanpa penjelasan tambahan.
''';

    final content = Content.text(prompt);
    final response = await _model.generateContent([content]);
    return response.text ?? '{}';
  }

  /// Generate environmental risk signals for a location
  Future<String> generateEnvironmentalSignals({String? location}) async {
    final locationInfo = location ?? 'Indonesia';
    final prompt = '''
Berikan analisis sinyal risiko lingkungan di wilayah $locationInfo dalam format JSON array:
[
  {
    "type": "Gempa/Banjir/Longsor/Gunung Meletus/Cuaca Ekstrem",
    "level": "Aman/Waspada/Peringatan Tinggi/Bahaya",
    "description": "Deskripsi singkat status risiko",
    "icon": "emoji relevan"
  }
]
Berikan 3-5 jenis risiko lingkungan. Level harus salah satu dari: Aman, Waspada, Peringatan Tinggi, Bahaya.
Jawab hanya dengan JSON array, tanpa penjelasan tambahan.
''';

    final content = Content.text(prompt);
    final response = await _model.generateContent([content]);
    return response.text ?? '[]';
  }

  /// Reset chat session
  void resetChat() {
    _chatSession = null;
  }
}
