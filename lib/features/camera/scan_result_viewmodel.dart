import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:eco/data/models/scan_result_model.dart';
import 'package:eco/data/repositories/gemini_repository.dart';
import 'package:eco/data/repositories/scan_repository.dart';
import 'package:eco/data/services/location_service.dart';
import 'package:eco/data/services/supabase_service.dart';

class ScanResultViewModel extends ChangeNotifier {
  final GeminiRepository _geminiRepository;
  final ScanRepository _scanRepository;
  final LocationService _locationService;

  bool _isAnalyzing = false;
  bool _isSaving = false;
  bool _isSaved = false;
  String? _errorMessage;
  String? _environmentCondition;
  String? _impactPrediction;
  String? _suggestions;
  List<ContactInfo> _contacts = [];
  String? _rawResponse;
  Uint8List? _imageBytes;
  String? _imageUrl;

  ScanResultViewModel({
    GeminiRepository? geminiRepository,
    ScanRepository? scanRepository,
    LocationService? locationService,
  })  : _geminiRepository = geminiRepository ?? GeminiRepository(),
        _scanRepository = scanRepository ?? ScanRepository(),
        _locationService = locationService ?? LocationService();

  // Getters
  bool get isAnalyzing => _isAnalyzing;
  bool get isSaving => _isSaving;
  bool get isSaved => _isSaved;
  String? get errorMessage => _errorMessage;
  String? get environmentCondition => _environmentCondition;
  String? get impactPrediction => _impactPrediction;
  String? get suggestions => _suggestions;
  List<ContactInfo> get contacts => _contacts;
  Uint8List? get imageBytes => _imageBytes;
  String? get imageUrl => _imageUrl;

  ScanResultModel get scanResult => ScanResultModel(
        id: '',
        userId: SupabaseService.currentUserId ?? '',
        imageUrl: _imageUrl ?? '',
        environmentCondition: _environmentCondition ?? '',
        impactPrediction: _impactPrediction ?? '',
        suggestions: _suggestions ?? '',
        contacts: _contacts,
        rawAiResponse: _rawResponse ?? '',
        createdAt: DateTime.now(),
        latitude: _locationService.lastPosition?.latitude,
        longitude: _locationService.lastPosition?.longitude,
        locationName: _locationService.lastLocationName,
      );

  /// Load an existing scan result (e.g. from history)
  void loadExistingResult(ScanResultModel result) {
    _imageBytes = null;
    _imageUrl = result.imageUrl;
    _environmentCondition = result.environmentCondition;
    _impactPrediction = result.impactPrediction;
    _suggestions = result.suggestions;
    _contacts = result.contacts;
    _rawResponse = result.rawAiResponse;
    _isSaved = true;
    _isSaving = false;
    _isAnalyzing = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Analyze the captured image
  Future<void> analyzeImage(Uint8List imageBytes) async {
    _imageBytes = imageBytes;
    _isAnalyzing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get location context
      String? locationContext;
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        locationContext = await _locationService.getLocationName(
          position.latitude,
          position.longitude,
        );
      }

      // Call Gemini for analysis
      final response = await _geminiRepository.analyzeImage(
        imageBytes: imageBytes,
        locationContext: locationContext,
      );

      _rawResponse = response;

      // Parse JSON response
      try {
        final jsonStr = _extractJson(response);
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;

        _environmentCondition =
            json['kondisi_lingkungan'] as String? ?? '';
        _impactPrediction =
            json['prediksi_dampak'] as String? ?? '';
        _suggestions =
            json['saran_penanganan'] as String? ?? '';

        final instansiList = json['instansi'] as List? ?? [];
        _contacts = instansiList
            .map((c) => ContactInfo.fromJson(c as Map<String, dynamic>))
            .toList();
      } catch (_) {
        // If JSON parsing fails, use raw response
        _environmentCondition = response;
        _impactPrediction = '';
        _suggestions = '';
        _contacts = [];
      }

      _isAnalyzing = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal menganalisis gambar: $e';
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// Save scan result to Supabase
  Future<void> saveResult() async {
    if (_imageBytes == null || _isSaving || _isSaved) return;

    _isSaving = true;
    notifyListeners();

    try {
      // Upload image
      final imageUrl = await _scanRepository.uploadImage(_imageBytes!);

      // Get location
      double? lat, lng;
      String? locName;
      final position = _locationService.lastPosition;
      if (position != null) {
        lat = position.latitude;
        lng = position.longitude;
        locName = _locationService.lastLocationName;
      }

      // Save to database
      final result = ScanResultModel(
        id: '',
        userId: SupabaseService.currentUserId ?? '',
        imageUrl: imageUrl,
        environmentCondition: _environmentCondition ?? '',
        impactPrediction: _impactPrediction ?? '',
        suggestions: _suggestions ?? '',
        contacts: _contacts,
        rawAiResponse: _rawResponse ?? '',
        createdAt: DateTime.now(),
        latitude: lat,
        longitude: lng,
        locationName: locName,
      );

      await _scanRepository.saveScanResult(result);

      _imageUrl = imageUrl;
      _isSaved = true;
      _isSaving = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal menyimpan: $e';
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Extract JSON from markdown code blocks
  String _extractJson(String text) {
    final jsonMatch =
        RegExp(r'```json?\s*([\s\S]*?)\s*```').firstMatch(text);
    if (jsonMatch != null) {
      return jsonMatch.group(1)!.trim();
    }
    return text.trim();
  }
}
