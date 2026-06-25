import 'package:flutter/material.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/core/constants/app_strings.dart';
import 'package:eco/core/widgets/light_glass_card.dart';
import 'package:eco/data/models/environmental_signal_model.dart';

/// Premium Environmental Signal Dashboard Widget — Light Mode
/// Features dynamic accent color based on signal level,
/// large warning icon with glow, risk level indicator,
/// and bottom detail strip with disaster/recommendation/time.
class EnvironmentalSignalCard extends StatelessWidget {
  final List<EnvironmentalSignalModel> signals;

  const EnvironmentalSignalCard({super.key, required this.signals});

  @override
  Widget build(BuildContext context) {
    if (signals.isEmpty) {
      return _SafeStateCard();
    }

    return Column(
      children: signals.map((signal) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _SignalCard(signal: signal),
        );
      }).toList(),
    );
  }
}

/// Card displayed when no signals / safe state
class _SafeStateCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LightGlassCard(
      padding: const EdgeInsets.all(24),
      accentBorderColor: AppColors.lightSignalSafe,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.lightSignalSafe.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      color: AppColors.lightSignalSafe,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Sinyal Ekologi',
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
                  color: AppColors.lightSignalSafe.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.lightSignalSafe.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Text(
                  AppStrings.levelSafe,
                  style: TextStyle(
                    color: AppColors.lightSignalSafe,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Safe State Content ─────────────────────────────────────
          Center(
            child: Column(
              children: [
                // Shield icon with glow
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lightSignalSafe.withValues(alpha: 0.08),
                    border: Border.all(
                      color: AppColors.lightSignalSafe.withValues(alpha: 0.15),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.lightSignalSafe,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Kondisi Wilayah Aman',
                  style: TextStyle(
                    color: AppColors.lightDarkEmerald,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tidak ada ancaman atau sinyal bahaya\nlingkungan di sekitar Anda.',
                  style: TextStyle(
                    color: AppColors.lightTextSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual signal card with dynamic accent color
class _SignalCard extends StatelessWidget {
  final EnvironmentalSignalModel signal;

  const _SignalCard({required this.signal});

  Color get _signalColor => AppColors.getLightSignalColor(signal.level);

  @override
  Widget build(BuildContext context) {
    return LightGlassCard(
      padding: const EdgeInsets.all(24),
      accentBorderColor: _signalColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _signalColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_active_outlined,
                      color: _signalColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Sinyal Ekologi',
                    style: TextStyle(
                      color: AppColors.lightTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              // Risk Level Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _signalColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _signalColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Text(
                  signal.level,
                  style: TextStyle(
                    color: _signalColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Center: Warning Icon + Status ─────────────────────────
          Center(
            child: Column(
              children: [
                // Signal icon with layered glow
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _signalColor.withValues(alpha: 0.08),
                    border: Border.all(
                      color: _signalColor.withValues(alpha: 0.15),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _signalColor.withValues(alpha: 0.12),
                        blurRadius: 20,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    signal.iconData,
                    color: _signalColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  signal.type,
                  style: const TextStyle(
                    color: AppColors.lightDarkEmerald,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  signal.description,
                  style: const TextStyle(
                    color: AppColors.lightTextSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Bottom: Details Strip ─────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _signalColor.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _signalColor.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _DetailChip(
                    icon: Icons.warning_amber_rounded,
                    label: 'Potensi',
                    value: signal.type,
                    color: _signalColor,
                  ),
                ),
                _VerticalDivider(color: _signalColor),
                Expanded(
                  child: _DetailChip(
                    icon: Icons.tips_and_updates_outlined,
                    label: 'Saran',
                    value: signal.recommendation.isNotEmpty
                        ? signal.recommendation
                        : 'Waspada',
                    color: _signalColor,
                  ),
                ),
                _VerticalDivider(color: _signalColor),
                Expanded(
                  child: _DetailChip(
                    icon: Icons.schedule_outlined,
                    label: 'Berlaku',
                    value: signal.effectiveTime.isNotEmpty
                        ? signal.effectiveTime
                        : 'Aktif',
                    color: _signalColor,
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
  final Color color;

  const _VerticalDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: color.withValues(alpha: 0.15),
    );
  }
}

/// Individual detail chip for signal information
class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color.withValues(alpha: 0.7),
          size: 16,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: AppColors.lightDarkEmerald,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: AppColors.lightTextMuted,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
