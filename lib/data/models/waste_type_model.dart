class WasteTypeModel {
  final String dominantType;
  final int percentage;
  final List<WasteItem> types;

  const WasteTypeModel({
    required this.dominantType,
    required this.percentage,
    required this.types,
  });

  factory WasteTypeModel.fromJson(Map<String, dynamic> json) {
    final typesList = (json['types'] as List?)
            ?.map((t) => WasteItem.fromJson(t as Map<String, dynamic>))
            .toList() ??
        [];
    return WasteTypeModel(
      dominantType: json['dominant_type'] as String? ?? 'Plastik',
      percentage: json['percentage'] as int? ?? 0,
      types: typesList,
    );
  }
}

class WasteItem {
  final String name;
  final int percentage;
  final String icon;

  const WasteItem({
    required this.name,
    required this.percentage,
    this.icon = '♻️',
  });

  factory WasteItem.fromJson(Map<String, dynamic> json) {
    return WasteItem(
      name: json['name'] as String? ?? '',
      percentage: json['percentage'] as int? ?? 0,
      icon: json['icon'] as String? ?? '♻️',
    );
  }
}
