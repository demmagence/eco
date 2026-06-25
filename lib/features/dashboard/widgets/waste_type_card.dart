import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/core/constants/app_strings.dart';
import 'package:eco/core/widgets/light_glass_card.dart';
import 'package:eco/data/models/waste_type_model.dart';

/// Premium Waste Analytics Dashboard Widget — Light Mode
/// Features a custom-painted donut chart with category segments,
/// dominant waste indicator, and categorized legend.
class WasteTypeCard extends StatelessWidget {
  final WasteTypeModel wasteType;

  const WasteTypeCard({super.key, required this.wasteType});

  /// Color palette for waste categories
  static const List<Color> _categoryColors = [
    Color(0xFF0F4D3A), // Emerald primary
    Color(0xFF34D399), // Accent emerald
    Color(0xFF1A6B53), // Secondary emerald
    Color(0xFF6EE7B7), // Light emerald
    Color(0xFF8BA69A), // Muted emerald
  ];

  Color _colorForIndex(int index) {
    return _categoryColors[index % _categoryColors.length];
  }

  @override
  Widget build(BuildContext context) {
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
                      Icons.pie_chart_outline_rounded,
                      color: AppColors.lightPrimaryEmerald,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    AppStrings.wasteType,
                    style: TextStyle(
                      color: AppColors.lightTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              // Dominant Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.lightPrimaryEmerald.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.lightBorder,
                    width: 1,
                  ),
                ),
                child: Text(
                  '${wasteType.dominantType} ${wasteType.percentage}%',
                  style: const TextStyle(
                    color: AppColors.lightPrimaryEmerald,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Center: Donut Chart + Legend ───────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Donut Chart
              SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: _DonutChartPainter(
                    items: wasteType.types,
                    colors: List.generate(
                      wasteType.types.length,
                      (i) => _colorForIndex(i),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${wasteType.types.length}',
                          style: const TextStyle(
                            color: AppColors.lightDarkEmerald,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                            height: 1.0,
                          ),
                        ),
                        const Text(
                          'Jenis',
                          style: TextStyle(
                            color: AppColors.lightTextMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // Legend
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    wasteType.types.length > 5 ? 5 : wasteType.types.length,
                    (index) {
                      final item = wasteType.types[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _LegendItem(
                          color: _colorForIndex(index),
                          name: item.name,
                          percentage: item.percentage,
                          isDominant: item.name.toLowerCase() ==
                              wasteType.dominantType.toLowerCase(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the donut chart
class _DonutChartPainter extends CustomPainter {
  final List<WasteItem> items;
  final List<Color> colors;

  _DonutChartPainter({
    required this.items,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 18.0;
    const gapAngle = 0.04; // Gap between segments in radians

    // Calculate total for percentage normalization
    final total = items.fold<int>(0, (sum, item) => sum + item.percentage);
    if (total <= 0) return;

    // Draw background ring
    final bgPaint = Paint()
      ..color = AppColors.lightBorder
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw segments
    double startAngle = -math.pi / 2; // Start from top

    for (int i = 0; i < items.length; i++) {
      final sweepAngle =
          (items[i].percentage / total) * (2 * math.pi) - gapAngle;

      if (sweepAngle <= 0) continue;

      final paint = Paint()
        ..color = colors[i]
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + gapAngle / 2,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => true;
}

/// Legend item for a waste category
class _LegendItem extends StatelessWidget {
  final Color color;
  final String name;
  final int percentage;
  final bool isDominant;

  const _LegendItem({
    required this.color,
    required this.name,
    required this.percentage,
    this.isDominant = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Color dot
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              color: isDominant
                  ? AppColors.lightDarkEmerald
                  : AppColors.lightTextSecondary,
              fontSize: 13,
              fontWeight: isDominant ? FontWeight.w700 : FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Percentage
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isDominant
                ? color.withValues(alpha: 0.1)
                : AppColors.lightBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$percentage%',
            style: TextStyle(
              color: isDominant ? color : AppColors.lightTextMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
