import 'package:flutter/material.dart';
import 'package:eco/core/constants/app_colors.dart';

/// A clean, simple card with subtle shadow and border.
/// No glassmorphism, no blur — just a clean white card.
class LightGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur; // kept for backward compat but unused
  final Color? borderColor;
  final VoidCallback? onTap;
  final Gradient? gradient; // kept for backward compat but unused
  final Color? accentBorderColor;

  const LightGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 16,
    this.blur = 0,
    this.borderColor,
    this.onTap,
    this.gradient,
    this.accentBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.lightCardBackground,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: accentBorderColor?.withValues(alpha: 0.2) ??
                borderColor ??
                AppColors.border,
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.lightShadow,
              blurRadius: 12,
              offset: Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
