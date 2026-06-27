import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/core/widgets/error_widget.dart';
import 'package:eco/core/widgets/shimmer_loading.dart';
import 'package:eco/features/auth/auth_viewmodel.dart';
import 'package:eco/features/dashboard/dashboard_viewmodel.dart';
import 'package:eco/features/dashboard/widgets/dashboard_app_bar.dart';
import 'package:eco/features/dashboard/widgets/dashboard_search_bar.dart';
import 'package:eco/features/dashboard/widgets/category_chips.dart';
import 'package:eco/features/dashboard/widgets/weather_card.dart';
import 'package:eco/features/dashboard/widgets/aqi_card.dart';
import 'package:eco/features/dashboard/widgets/water_quality_card.dart';
import 'package:eco/features/dashboard/widgets/waste_type_card.dart';
import 'package:eco/features/dashboard/widgets/environmental_signal_card.dart';
import 'package:eco/features/home/home_viewmodel.dart';
import 'package:eco/routes/app_router.dart';

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
    final user = context.watch<AuthViewModel>().user;

    return Consumer<DashboardViewModel>(
      builder: (context, dashVM, child) {
        if (dashVM.isLoading && dashVM.weather == null) {
          return const Scaffold(
            backgroundColor: AppColors.lightBackground, // LIGHT MODE
            body: SafeArea(
              child: DashboardShimmer(), // You might need to update shimmer colors too
            ),
          );
        }

        if (dashVM.errorMessage != null && dashVM.weather == null) {
          return Scaffold(
            backgroundColor: AppColors.lightBackground, // LIGHT MODE
            body: SafeArea(
              child: AppErrorWidget(
                message: dashVM.errorMessage!,
                onRetry: dashVM.refresh,
              ),
            ),
          );
        }

        final showWeather = dashVM.selectedCategory == DashboardCategory.all ||
            dashVM.selectedCategory == DashboardCategory.weather;
        final showEcology = dashVM.selectedCategory == DashboardCategory.all ||
            dashVM.selectedCategory == DashboardCategory.ecology;

        return Scaffold(
          backgroundColor: AppColors.lightBackground, // LIGHT MODE
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: dashVM.refresh,
              color: AppColors.lightPrimaryEmerald,
              backgroundColor: AppColors.lightCardBackground,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Custom App Bar
                  DashboardAppBar(
                    currentTime: dashVM.currentTime,
                    cityName: dashVM.cityName,
                    user: user,
                    onLocationTap: dashVM.refresh,
                    onProfileTap: () {
                      final authVM = context.read<AuthViewModel>();
                      Navigator.pushNamed(context, AppRouter.profile).then((_) {
                        // Reload user profile in case it changed
                        authVM.loadUserProfile();
                      });
                    },
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),

                  const SizedBox(height: 24),

                  // Search Bar with Filter
                  DashboardSearchBar(
                    query: dashVM.searchQuery,
                    onChanged: dashVM.setSearchQuery,
                    onFilterTap: () => showFilterBottomSheet(context),
                    results: dashVM.filteredFeatures,
                    onResultTap: (featureName) {
                      if (featureName == 'Cuaca' || featureName == 'Kualitas Udara') {
                        dashVM.setCategory(DashboardCategory.weather);
                        dashVM.setSearchQuery('');
                      } else if (featureName == 'Kualitas Air' || featureName == 'Prediksi Lingkungan') {
                        dashVM.setCategory(DashboardCategory.ecology);
                        dashVM.setSearchQuery('');
                      } else if (featureName == 'Kamera') {
                        context.read<HomeViewModel>().setIndex(1);
                        dashVM.setSearchQuery('');
                      } else if (featureName == 'Histori Scan') {
                        context.read<HomeViewModel>().setIndex(2);
                        dashVM.setSearchQuery('');
                      } else if (featureName == 'Chatbot') {
                        Navigator.pushNamed(context, AppRouter.chatbot);
                        dashVM.setSearchQuery('');
                      }
                    },
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                  const SizedBox(height: 20),

                  // Category Chips
                  CategoryChips(
                    selected: dashVM.selectedCategory,
                    onSelected: dashVM.setCategory,
                  ).animate().fadeIn(duration: 400.ms, delay: 150.ms),

                  const SizedBox(height: 24),

                  // Dynamic Cards list with stagger animation
                  Column(
                    children: [
                      // Weather & AQI Section
                      if (showWeather) ...[
                        if (dashVM.weather != null) ...[
                          WeatherCard(weather: dashVM.weather!),
                          const SizedBox(height: 16),
                          if (dashVM.aqi != null) ...[
                            AqiCard(aqi: dashVM.aqi!),
                            const SizedBox(height: 16),
                          ],
                        ] else ...[
                          _buildWeatherPlaceholderCard(),
                          const SizedBox(height: 16),
                        ],
                      ],

                      // Ecology Sections
                      if (showEcology && dashVM.waterQuality != null) ...[
                        WaterQualityCard(waterQuality: dashVM.waterQuality!),
                        const SizedBox(height: 16),
                      ],

                      if (showEcology && dashVM.wasteType != null) ...[
                        WasteTypeCard(wasteType: dashVM.wasteType!),
                        const SizedBox(height: 16),
                      ],

                      if (showEcology) ...[
                        EnvironmentalSignalCard(signals: dashVM.environmentalSignals),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.05, end: 0),

                  const SizedBox(height: 80), // extra padding for floating navigation bar
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherPlaceholderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.lightShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.wb_sunny_outlined, color: Colors.amber, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cuaca & Kualitas Udara',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Informasi cuaca tidak dapat dimuat karena OWM API key belum diatur atau tidak valid. Silakan atur "owmApiKey" di "api_constants.dart".',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.lightTextSecondary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
