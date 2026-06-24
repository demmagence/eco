class WaterQualityModel {
  final String status;
  final int cleanlinessLevel; // 1-100
  final String description;

  const WaterQualityModel({
    required this.status,
    required this.cleanlinessLevel,
    required this.description,
  });

  factory WaterQualityModel.fromJson(Map<String, dynamic> json) {
    return WaterQualityModel(
      status: json['status'] as String? ?? 'Sedang',
      cleanlinessLevel: json['cleanliness_level'] as int? ?? 50,
      description: json['description'] as String? ?? '',
    );
  }

  double get cleanlinessPercentage => cleanlinessLevel / 100.0;
}
