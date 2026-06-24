import 'package:flutter/material.dart';
import 'package:eco/core/constants/app_colors.dart';

class EnvironmentalSignalModel {
  final String type; // Gempa, Banjir, Longsor, etc.
  final String level; // Bahaya, Peringatan Tinggi, Waspada, Aman, etc.
  final String description;
  final String icon;

  const EnvironmentalSignalModel({
    required this.type,
    required this.level,
    required this.description,
    this.icon = '⚠️',
  });

  factory EnvironmentalSignalModel.fromJson(Map<String, dynamic> json) {
    return EnvironmentalSignalModel(
      type: json['type'] as String? ?? '',
      level: json['level'] as String? ?? 'Aman',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '⚠️',
    );
  }

  Color get color => AppColors.getSignalColor(level);

  IconData get iconData {
    switch (type.toLowerCase()) {
      case 'gempa':
        return Icons.vibration;
      case 'banjir':
        return Icons.water;
      case 'longsor':
        return Icons.landscape;
      case 'gunung meletus':
        return Icons.volcano;
      case 'cuaca ekstrem':
        return Icons.thunderstorm;
      default:
        return Icons.warning_amber;
    }
  }
}
