class WaterQualityModel {
  final String status;
  final int cleanlinessLevel; // 1-100
  final String description;
  final double ph;
  final double tds; // Total Dissolved Solids (mg/L)
  final double turbidity; // NTU
  final double temperature; // °C

  const WaterQualityModel({
    required this.status,
    required this.cleanlinessLevel,
    required this.description,
    this.ph = 7.0,
    this.tds = 150.0,
    this.turbidity = 1.0,
    this.temperature = 25.0,
  });

  factory WaterQualityModel.fromJson(Map<String, dynamic> json) {
    return WaterQualityModel(
      status: json['status'] as String? ?? 'Sedang',
      cleanlinessLevel: json['cleanliness_level'] as int? ?? 50,
      description: json['description'] as String? ?? '',
      ph: (json['ph'] as num?)?.toDouble() ?? 7.0,
      tds: (json['tds'] as num?)?.toDouble() ?? 150.0,
      turbidity: (json['turbidity'] as num?)?.toDouble() ?? 1.0,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 25.0,
    );
  }

  double get cleanlinessPercentage => cleanlinessLevel / 100.0;
}
