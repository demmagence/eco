import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/core/constants/app_strings.dart';
import 'package:eco/core/widgets/light_glass_card.dart';
import 'package:eco/data/models/water_quality_model.dart';

/// Premium Water Quality Dashboard Widget — Light Mode
/// Features a custom-painted water droplet with crystal wave effect,
/// water quality status, and detailed parameter metrics.
class WaterQualityCard extends StatelessWidget {
  final WaterQualityModel waterQuality;

  const WaterQualityCard({super.key, required this.waterQuality});

  Color get _statusColor {
    switch (waterQuality.status.toLowerCase()) {
      case 'bersih':
        return AppColors.lightSuccess;
      case 'tercemar':
        return AppColors.lightDanger;
      case 'sedang':
      default:
        return AppColors.lightWarning;
    }
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
                      Icons.water_drop_outlined,
                      color: AppColors.lightPrimaryEmerald,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    AppStrings.waterQuality,
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
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _statusColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Text(
                  waterQuality.status,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Center: Water Droplet + Status ────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Water Droplet Illustration
              SizedBox(
                width: 90,
                height: 110,
                child: CustomPaint(
                  painter: _WaterDropletPainter(
                    fillPercentage: waterQuality.cleanlinessPercentage,
                    statusColor: _statusColor,
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // Status Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${waterQuality.cleanlinessLevel}%',
                      style: const TextStyle(
                        color: AppColors.lightDarkEmerald,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.5,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.cleanlinessLevel,
                      style: const TextStyle(
                        color: AppColors.lightTextMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (waterQuality.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        waterQuality.description,
                        style: const TextStyle(
                          color: AppColors.lightTextSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Bottom: Parameters ────────────────────────────────────
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
                  child: _ParamChip(
                    label: 'pH',
                    value: waterQuality.ph.toStringAsFixed(1),
                    icon: Icons.science_outlined,
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _ParamChip(
                    label: 'TDS',
                    value: '${waterQuality.tds.toInt()}',
                    unit: 'mg/L',
                    icon: Icons.blur_on_outlined,
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _ParamChip(
                    label: 'Turb.',
                    value: waterQuality.turbidity.toStringAsFixed(1),
                    unit: 'NTU',
                    icon: Icons.opacity_outlined,
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _ParamChip(
                    label: 'Suhu',
                    value: '${waterQuality.temperature.toInt()}°',
                    icon: Icons.thermostat_outlined,
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

/// Custom painter for the water droplet with fill level
class _WaterDropletPainter extends CustomPainter {
  final double fillPercentage;
  final Color statusColor;

  _WaterDropletPainter({
    required this.fillPercentage,
    required this.statusColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final dropWidth = size.width * 0.7;
    final dropHeight = size.height * 0.85;
    final dropTop = size.height * 0.05;
    final dropBottom = dropTop + dropHeight;
    final dropCenterY = dropTop + dropHeight * 0.55;

    // Create droplet path
    final path = Path();
    path.moveTo(centerX, dropTop);

    // Right curve
    path.cubicTo(
      centerX + dropWidth * 0.15, dropTop + dropHeight * 0.15,
      centerX + dropWidth * 0.55, dropCenterY - dropHeight * 0.15,
      centerX + dropWidth * 0.5, dropCenterY + dropHeight * 0.05,
    );

    // Bottom right curve
    path.cubicTo(
      centerX + dropWidth * 0.48, dropCenterY + dropHeight * 0.3,
      centerX + dropWidth * 0.25, dropBottom,
      centerX, dropBottom,
    );

    // Bottom left curve
    path.cubicTo(
      centerX - dropWidth * 0.25, dropBottom,
      centerX - dropWidth * 0.48, dropCenterY + dropHeight * 0.3,
      centerX - dropWidth * 0.5, dropCenterY + dropHeight * 0.05,
    );

    // Left curve
    path.cubicTo(
      centerX - dropWidth * 0.55, dropCenterY - dropHeight * 0.15,
      centerX - dropWidth * 0.15, dropTop + dropHeight * 0.15,
      centerX, dropTop,
    );
    path.close();

    // Draw outer stroke
    final strokePaint = Paint()
      ..color = AppColors.lightBorder
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, strokePaint);

    // Clip to droplet shape for fill
    canvas.save();
    canvas.clipPath(path);

    // Fill background
    final bgPaint = Paint()
      ..color = statusColor.withValues(alpha: 0.06);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      bgPaint,
    );

    // Fill based on percentage
    final fillTop = dropBottom - (dropHeight * fillPercentage.clamp(0.0, 1.0));
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          statusColor.withValues(alpha: 0.15),
          statusColor.withValues(alpha: 0.35),
        ],
      ).createShader(Rect.fromLTWH(0, fillTop, size.width, dropBottom - fillTop));

    canvas.drawRect(
      Rect.fromLTWH(0, fillTop, size.width, dropBottom - fillTop),
      fillPaint,
    );

    // Small wave at the fill line
    final wavePath = Path();
    wavePath.moveTo(0, fillTop);
    for (double x = 0; x <= size.width; x += 1) {
      wavePath.lineTo(
        x,
        fillTop + math.sin(x * 0.15) * 3,
      );
    }
    wavePath.lineTo(size.width, dropBottom);
    wavePath.lineTo(0, dropBottom);
    wavePath.close();

    final wavePaint = Paint()
      ..color = statusColor.withValues(alpha: 0.08);
    canvas.drawPath(wavePath, wavePaint);

    canvas.restore();

    // Draw highlight reflection
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - dropWidth * 0.15, dropTop + dropHeight * 0.35),
        width: dropWidth * 0.15,
        height: dropHeight * 0.12,
      ),
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _WaterDropletPainter oldDelegate) =>
      oldDelegate.fillPercentage != fillPercentage ||
      oldDelegate.statusColor != statusColor;
}

/// Vertical divider between parameter chips
class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: AppColors.lightBorder,
    );
  }
}

/// Individual parameter chip
class _ParamChip extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final IconData icon;

  const _ParamChip({
    required this.label,
    required this.value,
    required this.icon,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: AppColors.lightSecondaryEmerald,
          size: 16,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.lightDarkEmerald,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          unit != null ? '$label ($unit)' : label,
          style: const TextStyle(
            color: AppColors.lightTextMuted,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
