import 'package:eco/data/models/weather_model.dart';
import 'package:eco/data/models/aqi_model.dart';
import 'package:eco/data/services/weather_service.dart';

class WeatherRepository {
  final WeatherService _weatherService;

  WeatherRepository({WeatherService? weatherService})
      : _weatherService = weatherService ?? WeatherService();

  Future<WeatherModel> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    return _weatherService.getWeather(
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<AqiModel> getAqi({
    required double latitude,
    required double longitude,
  }) async {
    return _weatherService.getAqi(
      latitude: latitude,
      longitude: longitude,
    );
  }

  void dispose() {
    _weatherService.dispose();
  }
}
