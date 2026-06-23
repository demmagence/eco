import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/core/constants/app_strings.dart';
import 'package:eco/core/widgets/loading_indicator.dart';
import 'package:eco/core/widgets/error_widget.dart';
import 'package:eco/features/auth/auth_viewmodel.dart';
import 'package:eco/features/dashboard/dashboard_viewmodel.dart';
import 'package:eco/features/dashboard/widgets/weather_card.dart';
import 'package:eco/features/dashboard/widgets/aqi_card.dart';
import 'package:eco/features/dashboard/widgets/scan_stats_card.dart';
import 'package:eco/features/dashboard/widgets/daily_tip_card.dart';
import 'package:eco/features/dashboard/widgets/news_card.dart';
import 'package:eco/features/dashboard/widgets/tps_map_card.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = context.read<AuthViewModel>();
      final dashVM = context.read<DashboardViewModel>();
      dashVM.setUserName(authVM.user?.displayName ?? 'User');
      dashVM.loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, dashVM, child) {
        if (dashVM.isLoading && dashVM.weather == null) {
          return const LoadingIndicator(message: 'Memuat dashboard...');
        }

        if (dashVM.errorMessage != null && dashVM.weather == null) {
          return AppErrorWidget(
            message: dashVM.errorMessage!,
            onRetry: dashVM.refresh,
          );
        }

        return RefreshIndicator(
          onRefresh: dashVM.refresh,
          color: AppColors.primary,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Welcome header
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppStrings.welcomeBack} ${dashVM.userName}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            dashVM.locationName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Weather & AQI row
              if (dashVM.weather != null || dashVM.aqi != null)
                Row(
                  children: [
                    if (dashVM.weather != null)
                      Expanded(
                        child: WeatherCard(weather: dashVM.weather!),
                      ),
                    if (dashVM.weather != null && dashVM.aqi != null)
                      const SizedBox(width: 12),
                    if (dashVM.aqi != null)
                      Expanded(
                        child: AqiCard(aqi: dashVM.aqi!),
                      ),
                  ],
                ),

              const SizedBox(height: 12),

              // Scan Stats
              ScanStatsCard(totalScans: dashVM.totalScans),

              const SizedBox(height: 12),

              // Daily Tip
              if (dashVM.dailyTip != null)
                DailyTipCard(
                  tip: dashVM.dailyTip!,
                  detail: dashVM.dailyTipDetail,
                  emoji: dashVM.dailyTipEmoji,
                ),

              if (dashVM.dailyTip != null) const SizedBox(height: 12),

              // News
              if (dashVM.news.isNotEmpty)
                NewsCard(newsList: dashVM.news),

              if (dashVM.news.isNotEmpty) const SizedBox(height: 12),

              // TPS Map
              const TpsMapCard(),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
