import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/core/constants/app_strings.dart';
import 'package:eco/core/widgets/light_glass_card.dart';
import 'package:eco/data/models/aqi_model.dart';

/// Premium Air Quality Dashboard Widget — Light Mode
/// Features a large circular AQI gauge with arc rendering,
/// status indicator, and pollutant detail metrics.
class AqiCard extends StatelessWidget {
  final AqiModel aqi;

  const AqiCard({super.key, required this.aqi});

  @override
  Widget build(BuildContext context) {
    final statusColor = aqi.color;

    return LightGlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Title + Location ───────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.lightAccentEmerald.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.air_outlined,
                      color: AppColors.lightPrimaryEmerald,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    AppStrings.airQuality,
                    style: TextStyle(
                      color: AppColors.lightTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Text(
                  aqi.label,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Center: AQI Gauge ─────────────────────────────────────
          Center(
            child: SizedBox(
              width: 160,
              height: 100,
              child: CustomPaint(
                painter: _AqiGaugePainter(
                  percentage: aqi.percentage,
                  statusColor: statusColor,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${aqi.aqi}',
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.5,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'AQI',
                          style: TextStyle(
                            color: AppColors.lightTextMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Bottom: Pollutant Details ──────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.lightBorder,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _PollutantChip(
                    label: 'PM2.5',
                    value: aqi.pm25.toStringAsFixed(1),
                    unit: 'μg/m³',
                    color: statusColor,
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _PollutantChip(
                    label: 'PM10',
                    value: aqi.pm10.toStringAsFixed(1),
                    unit: 'μg/m³',
                    color: statusColor,
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _PollutantChip(
                    label: 'O₃',
                    value: aqi.o3.toStringAsFixed(1),
                    unit: 'μg/m³',
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the semi-circular AQI gauge arc
class _AqiGaugePainter extends CustomPainter {
  final double percentage;
  final Color statusColor;

  _AqiGaugePainter({
    required this.percentage,
    required this.statusColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 12;

    // Background arc
    final bgPaint = Paint()
      ..color = AppColors.lightBorder
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      bgPaint,
    );

    // Value arc
    final valuePaint = Paint()
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..shader = SweepGradient(
        startAngle: math.pi,
        endAngle: math.pi * 2,
        colors: [
          statusColor.withValues(alpha: 0.5),
          statusColor,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final sweepAngle = math.pi * percentage.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      sweepAngle,
      false,
      valuePaint,
    );

    // Dot at end of arc
    final dotAngle = math.pi + sweepAngle;
    final dotX = center.dx + radius * math.cos(dotAngle);
    final dotY = center.dy + radius * math.sin(dotAngle);

    // Outer glow
    canvas.drawCircle(
      Offset(dotX, dotY),
      8,
      Paint()..color = statusColor.withValues(alpha: 0.15),
    );
    // Inner dot
    canvas.drawCircle(
      Offset(dotX, dotY),
      5,
      Paint()..color = statusColor,
    );
    // White center
    canvas.drawCircle(
      Offset(dotX, dotY),
      2.5,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _AqiGaugePainter oldDelegate) =>
      oldDelegate.percentage != percentage ||
      oldDelegate.statusColor != statusColor;
}

/// Vertical divider between pollutant chips
class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: AppColors.lightBorder,
    );
  }
}

/// Individual pollutant detail chip
class _PollutantChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _PollutantChip({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.lightTextMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: AppColors.lightDarkEmerald,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          unit,
          style: TextStyle(
            color: AppColors.lightTextMuted,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
