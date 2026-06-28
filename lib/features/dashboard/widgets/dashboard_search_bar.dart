import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/core/constants/app_strings.dart';

/// Glassmorphism search bar with filter button — Light Mode
class DashboardSearchBar extends StatelessWidget {
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final List<Map<String, dynamic>> results;
  final ValueChanged<String>? onResultTap;

  const DashboardSearchBar({
    super.key,
    required this.query,
    required this.onChanged,
    required this.onFilterTap,
    this.results = const [],
    this.onResultTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.lightCardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.lightBorder),
            boxShadow: const [
              BoxShadow(
                color: AppColors.lightShadow,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search,
                color: AppColors.lightTextMuted,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  onChanged: onChanged,
                  style: const TextStyle(
                    color: AppColors.lightTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    hintText: AppStrings.searchHint,
                    hintStyle: TextStyle(
                      color: AppColors.lightTextMuted,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onFilterTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.tune,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Search Results
        if (results.isNotEmpty) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.lightCardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightBorder),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.lightShadow,
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: results.map((feature) {
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        feature['icon'] as IconData,
                        color: AppColors.lightPrimaryEmerald,
                        size: 20,
                      ),
                      title: Text(
                        feature['name'] as String,
                        style: const TextStyle(
                          color: AppColors.lightTextPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () =>
                          onResultTap?.call(feature['name'] as String),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Filter bottom sheet content.
void showFilterBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.lightBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: AppColors.lightBorder),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lightTextMuted.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              AppStrings.filter,
              style: TextStyle(
                color: AppColors.lightTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _FilterChip(label: AppStrings.featureCuaca, icon: Icons.cloud_outlined),
                _FilterChip(
                    label: AppStrings.featureKualitasUdara, icon: Icons.air_outlined),
                _FilterChip(
                    label: AppStrings.featureKualitasAir,
                    icon: Icons.water_drop_outlined),
                _FilterChip(
                    label: AppStrings.featureHistoriScan, icon: Icons.history_outlined),
                _FilterChip(
                    label: AppStrings.featureHistoriChat,
                    icon: Icons.chat_bubble_outline),
                _FilterChip(
                    label: AppStrings.featureKamera, icon: Icons.camera_alt_outlined),
                _FilterChip(
                    label: AppStrings.featureChatbot, icon: Icons.smart_toy_outlined),
                _FilterChip(
                    label: AppStrings.featurePrediksiLingkungan,
                    icon: Icons.eco_outlined),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    },
  );
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _FilterChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightShadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.lightPrimaryEmerald, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.lightTextPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
