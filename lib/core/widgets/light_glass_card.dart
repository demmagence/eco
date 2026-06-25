import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:eco/core/constants/app_colors.dart';

/// A premium light-mode glassmorphism card with frosted-glass backdrop blur,
/// elevated white surface, emerald-tinted shadows, and subtle border.
/// Designed for luxury environmental dashboard widgets.
class LightGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final Color? borderColor;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? accentBorderColor;

  const LightGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 28,
    this.blur = 16,
    this.borderColor,
    this.onTap,
    this.gradient,
    this.accentBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: AppColors.lightCardBackground,
              gradient: gradient,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: accentBorderColor?.withValues(alpha: 0.2) ??
                    borderColor ??
                    AppColors.lightBorder,
                width: 1.5,
              ),
              boxShadow: [
                // Primary soft shadow
                BoxShadow(
                  color: AppColors.lightShadow,
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                // Subtle inner glow
                BoxShadow(
                  color: AppColors.lightAccentEmerald.withValues(alpha: 0.03),
                  blurRadius: 40,
                  offset: const Offset(0, 4),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
