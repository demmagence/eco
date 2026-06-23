import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eco/core/constants/api_constants.dart';
import 'package:eco/data/models/weather_model.dart';
import 'package:eco/data/models/aqi_model.dart';

class WeatherService {
  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  /// Get current weather by coordinates
  Future<WeatherModel> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse(
      '${ApiConstants.owmBaseUrl}${ApiConstants.owmWeatherEndpoint}'
      '?lat=$latitude&lon=$longitude'
      '&appid=${ApiConstants.owmApiKey}'
      '&units=metric&lang=id',
    );

    final response = await _client.get(url);

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data: ${response.statusCode}');
    }
  }

  /// Get Air Quality Index by coordinates
  Future<AqiModel> getAqi({
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse(
      '${ApiConstants.owmBaseUrl}${ApiConstants.owmAqiEndpoint}'
      '?lat=$latitude&lon=$longitude'
      '&appid=${ApiConstants.owmApiKey}',
    );

    final response = await _client.get(url);

    if (response.statusCode == 200) {
      return AqiModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load AQI data: ${response.statusCode}');
    }
  }

  void dispose() {
    _client.close();
  }
}
