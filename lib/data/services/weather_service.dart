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
    if (ApiConstants.owmApiKey == 'YOUR_OWM_API_KEY') {
      return const WeatherModel(
        temperature: 28.5,
        feelsLike: 30.2,
        humidity: 75,
        windSpeed: 3.4,
        description: 'berawan sebagian',
        icon: '03d',
        cityName: 'Jakarta',
      );
    }

    final url = Uri.parse(
      '${ApiConstants.owmBaseUrl}${ApiConstants.owmWeatherEndpoint}'
      '?lat=$latitude&lon=$longitude'
      '&appid=${ApiConstants.owmApiKey}'
      '&units=metric&lang=id',
    );

    try {
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        // Fallback to mock data if unauthorized
        return const WeatherModel(
          temperature: 28.5,
          feelsLike: 30.2,
          humidity: 75,
          windSpeed: 3.4,
          description: 'berawan sebagian (Demo)',
          icon: '03d',
          cityName: 'Jakarta (Demo)',
        );
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data on network exception
      return const WeatherModel(
        temperature: 28.5,
        feelsLike: 30.2,
        humidity: 75,
        windSpeed: 3.4,
        description: 'berawan sebagian (Offline)',
        icon: '03d',
        cityName: 'Jakarta (Offline)',
      );
    }
  }

  /// Get Air Quality Index by coordinates
  Future<AqiModel> getAqi({
    required double latitude,
    required double longitude,
  }) async {
    if (ApiConstants.owmApiKey == 'YOUR_OWM_API_KEY') {
      return const AqiModel(
        aqi: 2,
        co: 250.5,
        no: 0.1,
        no2: 15.2,
        o3: 45.0,
        so2: 5.4,
        pm25: 12.3,
        pm10: 22.1,
        nh3: 1.2,
      );
    }

    final url = Uri.parse(
      '${ApiConstants.owmBaseUrl}${ApiConstants.owmAqiEndpoint}'
      '?lat=$latitude&lon=$longitude'
      '&appid=${ApiConstants.owmApiKey}',
    );

    try {
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        return AqiModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        // Fallback to mock data if unauthorized
        return const AqiModel(
          aqi: 2,
          co: 250.5,
          no: 0.1,
          no2: 15.2,
          o3: 45.0,
          so2: 5.4,
          pm25: 12.3,
          pm10: 22.1,
          nh3: 1.2,
        );
      } else {
        throw Exception('Failed to load AQI data: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data on network exception
      return const AqiModel(
        aqi: 2,
        co: 250.5,
        no: 0.1,
        no2: 15.2,
        o3: 45.0,
        so2: 5.4,
        pm25: 12.3,
        pm10: 22.1,
        nh3: 1.2,
      );
    }
  }

  void dispose() {
    _client.close();
  }
}
