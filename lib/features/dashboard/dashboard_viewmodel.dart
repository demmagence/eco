import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:eco/data/models/weather_model.dart';
import 'package:eco/data/models/aqi_model.dart';
import 'package:eco/data/models/water_quality_model.dart';
import 'package:eco/data/models/waste_type_model.dart';
import 'package:eco/data/models/environmental_signal_model.dart';
import 'package:eco/data/repositories/weather_repository.dart';
import 'package:eco/data/repositories/gemini_repository.dart';
import 'package:eco/data/repositories/scan_repository.dart';
import 'package:eco/data/services/location_service.dart';

enum DashboardCategory { all, weather, ecology }

class DashboardViewModel extends ChangeNotifier {
  final WeatherRepository _weatherRepository;
  final GeminiRepository _geminiRepository;
  final ScanRepository _scanRepository;
  final LocationService _locationService;

  // ── Existing state ──────────────────────────────────────────────────
  WeatherModel? _weather;
  AqiModel? _aqi;
  int _totalScans = 0;
  String _locationName = 'Memuat lokasi...';
  String? _dailyTip;
  String? _dailyTipDetail;
  String? _dailyTipEmoji;
  List<Map<String, dynamic>> _news = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _userName = 'User';

  // ── New state ───────────────────────────────────────────────────────
  String _cityName = '';
  String _currentTime = '';
  DashboardCategory _selectedCategory = DashboardCategory.all;
  String _searchQuery = '';
  WaterQualityModel? _waterQuality;
  WasteTypeModel? _wasteType;
  List<EnvironmentalSignalModel> _environmentalSignals = [];
  Timer? _clockTimer;

  DashboardViewModel({
    WeatherRepository? weatherRepository,
    GeminiRepository? geminiRepository,
    ScanRepository? scanRepository,
    LocationService? locationService,
  })  : _weatherRepository = weatherRepository ?? WeatherRepository(),
        _geminiRepository = geminiRepository ?? GeminiRepository(),
        _scanRepository = scanRepository ?? ScanRepository(),
        _locationService = locationService ?? LocationService() {
    _startClock();
  }

  // ── Getters ─────────────────────────────────────────────────────────
  WeatherModel? get weather => _weather;
  AqiModel? get aqi => _aqi;
  int get totalScans => _totalScans;
  String get locationName => _locationName;
  String? get dailyTip => _dailyTip;
  String? get dailyTipDetail => _dailyTipDetail;
  String? get dailyTipEmoji => _dailyTipEmoji;
  List<Map<String, dynamic>> get news => _news;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get userName => _userName;
  String get cityName => _cityName;
  String get currentTime => _currentTime;
  DashboardCategory get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  WaterQualityModel? get waterQuality => _waterQuality;
  WasteTypeModel? get wasteType => _wasteType;
  List<EnvironmentalSignalModel> get environmentalSignals =>
      _environmentalSignals;

  // ── Search features ─────────────────────────────────────────────────
  static const List<Map<String, dynamic>> _searchableFeatures = [
    {'name': 'Cuaca', 'icon': Icons.cloud, 'category': 'weather'},
    {'name': 'Kualitas Udara', 'icon': Icons.air, 'category': 'weather'},
    {'name': 'Kualitas Air', 'icon': Icons.water_drop, 'category': 'weather'},
    {'name': 'Histori Scan', 'icon': Icons.history, 'category': 'general'},
    {'name': 'Histori Chat', 'icon': Icons.chat_bubble, 'category': 'general'},
    {'name': 'Kamera', 'icon': Icons.camera_alt, 'category': 'general'},
    {'name': 'Chatbot', 'icon': Icons.smart_toy, 'category': 'general'},
    {
      'name': 'Prediksi Lingkungan',
      'icon': Icons.eco,
      'category': 'ecology',
    },
  ];

  List<Map<String, dynamic>> get filteredFeatures {
    if (_searchQuery.isEmpty) return [];
    return _searchableFeatures
        .where((f) => (f['name'] as String)
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // ── Setters ─────────────────────────────────────────────────────────
  void setUserName(String name) {
    _userName = name;
  }

  void setCategory(DashboardCategory category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ── Clock ───────────────────────────────────────────────────────────
  void _startClock() {
    _updateTime();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    _currentTime = '$h:$m';
    notifyListeners();
  }

  // ── Data loading ────────────────────────────────────────────────────

  /// Load all dashboard data
  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get location first
      final position = await _locationService.getCurrentPosition();

      if (position != null) {
        // Load location name
        _locationName = await _locationService.getLocationName(
          position.latitude,
          position.longitude,
        );
        _cityName = await _locationService.getCityName(
          position.latitude,
          position.longitude,
        );
        notifyListeners();

        // Load scan count
        try {
          _totalScans = await _scanRepository.getScanCount();
        } catch (scanErr) {
          debugPrint('Scan count load failed: $scanErr');
          _totalScans = 0;
        }

        // Load weather and AQI in parallel (non-blocking)
        try {
          final weatherResults = await Future.wait([
            _weatherRepository.getWeather(
              latitude: position.latitude,
              longitude: position.longitude,
            ),
            _weatherRepository.getAqi(
              latitude: position.latitude,
              longitude: position.longitude,
            ),
          ]);
          _weather = weatherResults[0] as WeatherModel;
          _aqi = weatherResults[1] as AqiModel;
        } catch (weatherErr) {
          debugPrint('Weather or AQI load failed: $weatherErr');
          _weather = null;
          _aqi = null;
        }
      } else {
        _locationName = 'Lokasi tidak tersedia';
        _cityName = 'Lokasi';
        _totalScans = await _scanRepository.getScanCount();
      }

      // Load AI content (non-blocking)
      _loadAiContent();
      _loadEcologyData();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load AI-generated content (tips & news)
  Future<void> _loadAiContent() async {
    try {
      // Load daily tip
      final tipResponse = await _geminiRepository.generateDailyTip();
      try {
        final tipJson = jsonDecode(_extractJson(tipResponse));
        _dailyTip = tipJson['tips'] as String?;
        _dailyTipDetail = tipJson['detail'] as String?;
        _dailyTipEmoji = tipJson['emoji'] as String?;
      } catch (_) {
        _dailyTip = tipResponse;
      }
      notifyListeners();

      // Load news
      final newsResponse =
          await _geminiRepository.generateNews(location: _locationName);
      try {
        final newsJson = jsonDecode(_extractJson(newsResponse)) as List;
        _news =
            newsJson.map((n) => n as Map<String, dynamic>).toList();
      } catch (_) {
        _news = [];
      }
      notifyListeners();
    } catch (_) {
      // AI content is non-critical, silently fail
    }
  }

  /// Load ecology data (water quality, waste types, environmental signals)
  Future<void> _loadEcologyData() async {
    try {
      // Load in parallel
      final results = await Future.wait([
        _geminiRepository.generateWaterQuality(location: _locationName),
        _geminiRepository.generateWasteAnalysis(location: _locationName),
        _geminiRepository.generateEnvironmentalSignals(
            location: _locationName),
      ]);

      // Parse water quality
      try {
        final wqJson = jsonDecode(_extractJson(results[0]));
        _waterQuality = WaterQualityModel.fromJson(wqJson);
      } catch (_) {}

      // Parse waste types
      try {
        final wtJson = jsonDecode(_extractJson(results[1]));
        _wasteType = WasteTypeModel.fromJson(wtJson);
      } catch (_) {}

      // Parse environmental signals
      try {
        final esJson = jsonDecode(_extractJson(results[2])) as List;
        _environmentalSignals = esJson
            .map((s) =>
                EnvironmentalSignalModel.fromJson(s as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _environmentalSignals = [];
      }

      notifyListeners();
    } catch (_) {
      // Ecology data is non-critical
    }
  }

  /// Extract JSON from a response that may contain markdown code blocks
  String _extractJson(String text) {
    // Remove markdown code block markers
    final jsonMatch = RegExp(r'```json?\s*([\s\S]*?)\s*```').firstMatch(text);
    if (jsonMatch != null) {
      return jsonMatch.group(1)!.trim();
    }
    return text.trim();
  }

  /// Refresh dashboard data
  Future<void> refresh() async {
    await loadDashboard();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }
}
