import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/core/constants/app_strings.dart';
import 'package:eco/core/widgets/light_glass_card.dart';
import 'package:eco/data/models/weather_model.dart';

/// Premium Weather Dashboard Widget — Light Mode
/// Apple-level glassmorphism card with elegant weather illustration,
/// large temperature display, and premium detail chips.
class WeatherCard extends StatelessWidget {
  final WeatherModel weather;

  const WeatherCard({super.key, required this.weather});

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
                      Icons.wb_sunny_outlined,
                      color: AppColors.lightPrimaryEmerald,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    AppStrings.weather,
                    style: TextStyle(
                      color: AppColors.lightTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: AppColors.lightSecondaryEmerald,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      weather.cityName.isNotEmpty
                          ? weather.cityName
                          : 'Lokasi',
                      style: const TextStyle(
                        color: AppColors.lightSecondaryEmerald,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Center: Weather Illustration + Temperature ─────────────
          Row(
            children: [
              // Weather icon with decorative glow
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow effect
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.lightAccentEmerald.withValues(alpha: 0.12),
                          AppColors.lightAccentEmerald.withValues(alpha: 0.03),
                          Colors.transparent,
                        ],
                        stops: const [0.3, 0.7, 1.0],
                      ),
                    ),
                  ),
                  // Weather icon
                  CachedNetworkImage(
                    imageUrl: weather.iconUrl,
                    width: 68,
                    height: 68,
                    errorWidget: (_, _, _) => Icon(
                      Icons.wb_sunny_rounded,
                      color: AppColors.lightAccentEmerald,
                      size: 56,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // Temperature + Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.temperatureString,
                      style: const TextStyle(
                        color: AppColors.lightDarkEmerald,
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -2,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weather.descriptionCapitalized,
                      style: const TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Bottom: Detail Chips ──────────────────────────────────
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
                  child: _WeatherDetailChip(
                    icon: Icons.water_drop_outlined,
                    label: AppStrings.humidity,
                    value: weather.humidityString,
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _WeatherDetailChip(
                    icon: Icons.air_outlined,
                    label: AppStrings.wind,
                    value: weather.windSpeedString,
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _WeatherDetailChip(
                    icon: Icons.thermostat_outlined,
                    label: 'Terasa',
                    value: weather.feelsLikeString,
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

/// Vertical divider between detail chips
class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: AppColors.lightBorder,
    );
  }
}

/// Individual weather detail chip
class _WeatherDetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeatherDetailChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: AppColors.lightSecondaryEmerald,
          size: 18,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.lightDarkEmerald,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.lightTextMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
