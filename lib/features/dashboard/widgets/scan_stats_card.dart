import 'package:flutter/material.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/core/constants/app_strings.dart';

class ScanStatsCard extends StatelessWidget {
  final int totalScans;

  const ScanStatsCard({super.key, required this.totalScans});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.document_scanner,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.scanStats,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalScans',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const Text(
                  AppStrings.totalScans,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.trending_up,
                  color: AppColors.accent,
                  size: 24,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
