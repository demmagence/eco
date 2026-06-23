import 'package:flutter/material.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/core/constants/app_strings.dart';

class DailyTipCard extends StatelessWidget {
  final String tip;
  final String? detail;
  final String? emoji;

  const DailyTipCard({
    super.key,
    required this.tip,
    this.detail,
    this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.accent.withValues(alpha: 0.08),
              AppColors.accent.withValues(alpha: 0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.accent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  AppStrings.dailyTip,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
                if (emoji != null) ...[
                  const Spacer(),
                  Text(
                    emoji!,
                    style: const TextStyle(fontSize: 24),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              tip,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
                height: 1.4,
              ),
            ),
            if (detail != null) ...[
              const SizedBox(height: 8),
              Text(
                detail!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
