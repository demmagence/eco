import 'package:flutter/material.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/core/constants/app_strings.dart';

class NewsCard extends StatelessWidget {
  final List<Map<String, dynamic>> newsList;

  const NewsCard({super.key, required this.newsList});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.newspaper,
                  color: AppColors.secondary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  AppStrings.environmentNews,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...newsList.map((news) => _NewsItem(news: news)),
          ],
        ),
      ),
    );
  }
}

class _NewsItem extends StatelessWidget {
  final Map<String, dynamic> news;

  const _NewsItem({required this.news});

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'sampah':
        return Icons.delete_outline;
      case 'polusi':
        return Icons.factory_outlined;
      case 'iklim':
        return Icons.thermostat;
      case 'konservasi':
        return Icons.park_outlined;
      default:
        return Icons.article_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(news['kategori'] as String?),
              color: AppColors.secondary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news['judul'] as String? ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  news['ringkasan'] as String? ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
