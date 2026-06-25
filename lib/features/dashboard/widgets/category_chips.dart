import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/core/constants/app_strings.dart';
import 'package:eco/features/dashboard/dashboard_viewmodel.dart';

/// Horizontal category chips — Light Mode: All, Weather, Ecology.
class CategoryChips extends StatelessWidget {
  final DashboardCategory selected;
  final ValueChanged<DashboardCategory> onSelected;

  const CategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _Chip(
            label: AppStrings.categoryAll,
            icon: Icons.apps,
            isSelected: selected == DashboardCategory.all,
            onTap: () => onSelected(DashboardCategory.all),
          ),
          const SizedBox(width: 10),
          _Chip(
            label: AppStrings.categoryWeather,
            icon: Icons.cloud_outlined,
            isSelected: selected == DashboardCategory.weather,
            onTap: () => onSelected(DashboardCategory.weather),
          ),
          const SizedBox(width: 10),
          _Chip(
            label: AppStrings.categoryEcology,
            icon: Icons.eco_outlined,
            isSelected: selected == DashboardCategory.ecology,
            onTap: () => onSelected(DashboardCategory.ecology),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.lightPrimaryEmerald
              : AppColors.lightCardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.lightPrimaryEmerald
                : AppColors.lightBorder,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.lightPrimaryEmerald.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.lightShadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : AppColors.lightTextSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : AppColors.lightTextSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
