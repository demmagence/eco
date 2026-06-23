import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:eco/data/models/weather_model.dart';
import 'package:eco/data/models/aqi_model.dart';
import 'package:eco/data/repositories/weather_repository.dart';
import 'package:eco/data/repositories/gemini_repository.dart';
import 'package:eco/data/repositories/scan_repository.dart';
import 'package:eco/data/services/location_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final WeatherRepository _weatherRepository;
  final GeminiRepository _geminiRepository;
  final ScanRepository _scanRepository;
  final LocationService _locationService;

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

  DashboardViewModel({
    WeatherRepository? weatherRepository,
    GeminiRepository? geminiRepository,
    ScanRepository? scanRepository,
    LocationService? locationService,
  })  : _weatherRepository = weatherRepository ?? WeatherRepository(),
        _geminiRepository = geminiRepository ?? GeminiRepository(),
        _scanRepository = scanRepository ?? ScanRepository(),
        _locationService = locationService ?? LocationService();

  // Getters
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

  void setUserName(String name) {
    _userName = name;
  }

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
        notifyListeners();

        // Load weather and AQI in parallel
        final results = await Future.wait([
          _weatherRepository.getWeather(
            latitude: position.latitude,
            longitude: position.longitude,
          ),
          _weatherRepository.getAqi(
            latitude: position.latitude,
            longitude: position.longitude,
          ),
          _scanRepository.getScanCount(),
        ]);

        _weather = results[0] as WeatherModel;
        _aqi = results[1] as AqiModel;
        _totalScans = results[2] as int;
      } else {
        _locationName = 'Lokasi tidak tersedia';
        _totalScans = await _scanRepository.getScanCount();
      }

      // Load AI content (non-blocking)
      _loadAiContent();

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
}
