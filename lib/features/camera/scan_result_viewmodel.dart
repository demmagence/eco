import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:eco/data/models/scan_result_model.dart';
import 'package:eco/data/repositories/gemini_repository.dart';
import 'package:eco/data/repositories/scan_repository.dart';
import 'package:eco/data/services/location_service.dart';
import 'package:eco/data/services/api_service.dart';

class ScanResultViewModel extends ChangeNotifier {
  final GeminiRepository _geminiRepository;
  final ScanRepository _scanRepository;
  final LocationService _locationService;

  bool _isAnalyzing = false;
  bool _isSaving = false;
  bool _isSaved = false;
  String? _errorMessage;

  // ── Common ──────────────────────────────────────────────────
  String _scanType = 'multiple';

  // ── Multiple scan mode fields ────────────────────────────────
  String? _environmentCondition;
  String? _impactPrediction;
  String? _suggestions;
  List<ContactInfo> _contacts = [];

  // ── Single scan mode fields ──────────────────────────────────
  String? _correctDisposal;
  String? _teacherMaterial;
  String? _trashClassification;
  String? _recyclingInfo;

  // ── Image ────────────────────────────────────────────────────
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

  // ── Getters ──────────────────────────────────────────────────
  bool get isAnalyzing => _isAnalyzing;
  bool get isSaving => _isSaving;
  bool get isSaved => _isSaved;
  String? get errorMessage => _errorMessage;
  String get scanType => _scanType;

  // Multiple mode
  String? get environmentCondition => _environmentCondition;
  String? get impactPrediction => _impactPrediction;
  String? get suggestions => _suggestions;
  List<ContactInfo> get contacts => _contacts;

  // Single mode
  String? get correctDisposal => _correctDisposal;
  String? get teacherMaterial => _teacherMaterial;
  String? get trashClassification => _trashClassification;
  String? get recyclingInfo => _recyclingInfo;

  Uint8List? get imageBytes => _imageBytes;
  String? get imageUrl => _imageUrl;

  ScanResultModel get scanResult => ScanResultModel(
        id: '',
        userId: ApiService.currentUserId ?? '',
        imageUrl: _imageUrl ?? '',
        scanType: _scanType,
        environmentCondition: _environmentCondition,
        impactPrediction: _impactPrediction,
        suggestions: _suggestions,
        contacts: _contacts,
        correctDisposal: _correctDisposal,
        teacherMaterial: _teacherMaterial,
        trashClassification: _trashClassification,
        recyclingInfo: _recyclingInfo,
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
    _scanType = result.scanType;
    _environmentCondition = result.environmentCondition;
    _impactPrediction = result.impactPrediction;
    _suggestions = result.suggestions;
    _contacts = result.contacts;
    _correctDisposal = result.correctDisposal;
    _teacherMaterial = result.teacherMaterial;
    _trashClassification = result.trashClassification;
    _recyclingInfo = result.recyclingInfo;
    _rawResponse = result.rawAiResponse;
    _isSaved = true;
    _isSaving = false;
    _isAnalyzing = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Analyze the captured image in the given scan mode
  Future<void> analyzeImage(Uint8List imageBytes, {String scanMode = 'multiple'}) async {
    _imageBytes = imageBytes;
    _scanType = scanMode;
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
        scanMode: scanMode,
      );

      _rawResponse = response;

      // Parse JSON response
      try {
        final jsonStr = _extractJson(response);
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;

        if (scanMode == 'single') {
          _correctDisposal = json['cara_buang'] as String? ?? '';
          _teacherMaterial = json['materi_edukasi'] as String? ?? '';
          _trashClassification = json['pengelompokan'] as String? ?? '';
          _recyclingInfo = json['daur_ulang'] as String? ?? '';
          // Clear multiple mode fields
          _environmentCondition = null;
          _impactPrediction = null;
          _suggestions = null;
          _contacts = [];
        } else {
          _environmentCondition = json['kondisi_lingkungan'] as String? ?? '';
          _impactPrediction = json['prediksi_dampak'] as String? ?? '';
          _suggestions = json['saran_penanganan'] as String? ?? '';
          final instansiList = json['instansi'] as List? ?? [];
          _contacts = instansiList
              .map((c) => ContactInfo.fromJson(c as Map<String, dynamic>))
              .toList();
          // Clear single mode fields
          _correctDisposal = null;
          _teacherMaterial = null;
          _trashClassification = null;
          _recyclingInfo = null;
        }
      } catch (_) {
        // Fallback for non-JSON response
        if (scanMode == 'single') {
          _correctDisposal = response;
        } else {
          _environmentCondition = response;
        }
      }

      _isAnalyzing = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal menganalisis gambar: $e';
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// Save scan result to local server
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

      // Build result based on mode
      final result = ScanResultModel(
        id: '',
        userId: ApiService.currentUserId ?? '',
        imageUrl: imageUrl,
        scanType: _scanType,
        environmentCondition: _environmentCondition,
        impactPrediction: _impactPrediction,
        suggestions: _suggestions,
        contacts: _contacts,
        correctDisposal: _correctDisposal,
        teacherMaterial: _teacherMaterial,
        trashClassification: _trashClassification,
        recyclingInfo: _recyclingInfo,
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
