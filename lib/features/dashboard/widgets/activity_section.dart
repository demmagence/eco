import 'package:flutter/material.dart';
import 'package:eco/core/constants/app_colors.dart';

/// "Aktivitas Lingkungan" section showing Total Scan and Member Since
class ActivitySection extends StatelessWidget {
  final int totalScans;
  final DateTime? memberSince;

  const ActivitySection({
    super.key,
    required this.totalScans,
    this.memberSince,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aktivitas Lingkungan',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Total Scan Card
            Expanded(
              child: _ActivityCard(
                icon: Icons.qr_code_scanner_rounded,
                iconColor: AppColors.secondary,
                value: totalScans.toString(),
                label: 'Total Scan',
              ),
            ),
            const SizedBox(width: 12),
            // Member Since Card
            Expanded(
              child: _ActivityCard(
                icon: Icons.calendar_today_rounded,
                iconColor: AppColors.accentDark,
                value: _formatDate(memberSince),
                label: 'Anggota Sejak',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _ActivityCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.lightShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
