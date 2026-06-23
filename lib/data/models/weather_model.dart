class WeatherModel {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String description;
  final String icon;
  final String cityName;

  const WeatherModel({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
    required this.cityName,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;
    final weatherList = json['weather'] as List;
    final weather = weatherList.first as Map<String, dynamic>;

    return WeatherModel(
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      humidity: main['humidity'] as int,
      windSpeed: (wind['speed'] as num).toDouble(),
      description: weather['description'] as String? ?? '',
      icon: weather['icon'] as String? ?? '01d',
      cityName: json['name'] as String? ?? '',
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  String get temperatureString => '${temperature.round()}°C';
  String get feelsLikeString => '${feelsLike.round()}°C';
  String get humidityString => '$humidity%';
  String get windSpeedString => '${windSpeed.toStringAsFixed(1)} m/s';
  String get descriptionCapitalized =>
      description.isNotEmpty
          ? description[0].toUpperCase() + description.substring(1)
          : '';
}
