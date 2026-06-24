import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:eco/core/constants/app_colors.dart';

/// Shimmer / skeleton loading widgets for the dark glassmorphism theme.
class ShimmerLoading extends StatelessWidget {
  final Widget child;

  const ShimmerLoading({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.primaryEmerald.withValues(alpha: 0.3),
      highlightColor: AppColors.secondaryEmerald.withValues(alpha: 0.5),
      child: child,
    );
  }
}

/// A rectangular shimmer placeholder.
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.primaryEmerald,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// A circular shimmer placeholder (e.g., for avatars).
class ShimmerCircle extends StatelessWidget {
  final double size;

  const ShimmerCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primaryEmerald,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// A full card shimmer (mimics a dashboard card skeleton).
class ShimmerCard extends StatelessWidget {
  final double height;

  const ShimmerCard({super.key, this.height = 160});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.primaryEmerald,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}

/// Dashboard skeleton loading state.
class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App bar shimmer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerBox(width: 60, height: 14),
                  SizedBox(height: 6),
                  ShimmerBox(width: 100, height: 18),
                ],
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      ShimmerBox(width: 80, height: 14),
                      SizedBox(height: 4),
                      ShimmerBox(width: 60, height: 12),
                    ],
                  ),
                  const SizedBox(width: 12),
                  const ShimmerCircle(size: 44),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Search bar
          const ShimmerBox(width: double.infinity, height: 52),
          const SizedBox(height: 20),
          // Category chips
          Row(
            children: const [
              ShimmerBox(width: 70, height: 36),
              SizedBox(width: 10),
              ShimmerBox(width: 80, height: 36),
              SizedBox(width: 10),
              ShimmerBox(width: 80, height: 36),
            ],
          ),
          const SizedBox(height: 24),
          // Cards
          Row(
            children: const [
              Expanded(child: ShimmerCard(height: 180)),
              SizedBox(width: 12),
              Expanded(child: ShimmerCard(height: 180)),
            ],
          ),
          const SizedBox(height: 16),
          const ShimmerCard(height: 140),
        ],
      ),
    );
  }
}
