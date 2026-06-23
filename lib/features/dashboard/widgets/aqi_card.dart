import 'package:flutter/material.dart';
import 'package:eco/core/constants/app_strings.dart';
import 'package:eco/data/models/aqi_model.dart';

class AqiCard extends StatelessWidget {
  final AqiModel aqi;

  const AqiCard({super.key, required this.aqi});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: aqi.color.withValues(alpha: 0.1),
          border: Border.all(
            color: aqi.color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.air, color: aqi.color, size: 16),
                const SizedBox(width: 4),
                Text(
                  AppStrings.airQuality,
                  style: TextStyle(
                    color: aqi.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // AQI gauge
            Center(
              child: SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: aqi.percentage,
                      strokeWidth: 6,
                      backgroundColor: aqi.color.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation(aqi.color),
                    ),
                    Text(
                      '${aqi.aqi}',
                      style: TextStyle(
                        color: aqi.color,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                aqi.label,
                style: TextStyle(
                  color: aqi.color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            // PM2.5 info
            Center(
              child: Text(
                'PM2.5: ${aqi.pm25.toStringAsFixed(1)} \u03bcg/m\u00b3',
                style: TextStyle(
                  color: aqi.color.withValues(alpha: 0.8),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
