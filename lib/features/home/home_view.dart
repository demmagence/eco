import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/core/constants/app_strings.dart';
import 'package:eco/features/home/home_viewmodel.dart';
import 'package:eco/features/history/history_viewmodel.dart';
import 'package:eco/features/dashboard/dashboard_view.dart';
import 'package:eco/features/camera/camera_view.dart';
import 'package:eco/features/history/history_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Consumer<HomeViewModel>(
        builder: (context, homeVM, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                AppStrings.appName,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              actions: [
                // Profile icon
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: const CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.surfaceVariant,
                      child: Icon(
                        Icons.person,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/profile');
                    },
                  ),
                ),
              ],
            ),
            body: IndexedStack(
              index: homeVM.currentIndex,
              children: const [
                DashboardView(),
                CameraView(),
                HistoryView(),
              ],
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: homeVM.currentIndex,
                onTap: (index) {
                  homeVM.setIndex(index);
                  // Refresh history data whenever the History tab is opened
                  if (index == 2) {
                    context.read<HistoryViewModel>().loadHistory();
                  }
                },
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard_outlined),
                    activeIcon: Icon(Icons.dashboard),
                    label: AppStrings.dashboard,
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: homeVM.currentIndex == 1
                            ? AppColors.primary
                            : AppColors.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: homeVM.currentIndex == 1
                            ? Colors.white
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                    label: AppStrings.camera,
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.history_outlined),
                    activeIcon: Icon(Icons.history),
                    label: AppStrings.history,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
