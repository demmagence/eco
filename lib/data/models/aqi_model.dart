import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

class AqiModel {
  final int aqi;
  final double co;
  final double no;
  final double no2;
  final double o3;
  final double so2;
  final double pm25;
  final double pm10;
  final double nh3;

  const AqiModel({
    required this.aqi,
    required this.co,
    required this.no,
    required this.no2,
    required this.o3,
    required this.so2,
    required this.pm25,
    required this.pm10,
    required this.nh3,
  });

  factory AqiModel.fromJson(Map<String, dynamic> json) {
    final list = json['list'] as List;
    final data = list.first as Map<String, dynamic>;
    final main = data['main'] as Map<String, dynamic>;
    final components = data['components'] as Map<String, dynamic>;

    return AqiModel(
      aqi: main['aqi'] as int,
      co: (components['co'] as num?)?.toDouble() ?? 0,
      no: (components['no'] as num?)?.toDouble() ?? 0,
      no2: (components['no2'] as num?)?.toDouble() ?? 0,
      o3: (components['o3'] as num?)?.toDouble() ?? 0,
      so2: (components['so2'] as num?)?.toDouble() ?? 0,
      pm25: (components['pm2_5'] as num?)?.toDouble() ?? 0,
      pm10: (components['pm10'] as num?)?.toDouble() ?? 0,
      nh3: (components['nh3'] as num?)?.toDouble() ?? 0,
    );
  }

  String get label => AppStrings.getAqiLabel(aqi);
  Color get color => AppColors.getAqiColor(aqi);

  /// Percentage for gauge (1=20%, 2=40%, 3=60%, 4=80%, 5=100%)
  double get percentage => aqi / 5.0;
}
