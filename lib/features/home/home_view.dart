import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            backgroundColor: AppColors.backgroundPrimary,
            extendBody: true, // Allow content to flow under the floating bottom bar
            body: IndexedStack(
              index: homeVM.currentIndex,
              children: const [
                DashboardView(),
                CameraView(),
                HistoryView(),
              ],
            ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: _FloatingBottomBar(
                  currentIndex: homeVM.currentIndex,
                  onTap: (index) {
                    HapticFeedback.mediumImpact();
                    homeVM.setIndex(index);
                    if (index == 2) {
                      context.read<HistoryViewModel>().loadHistory();
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FloatingBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingBottomBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.lightPrimaryEmerald,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightPrimaryEmerald.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Dashboard Tab
          _NavBarItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: AppStrings.dashboard,
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
          ),

          // Camera Tab (Floating Center Button)
          _CameraFloatingButton(
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
          ),

          // History Tab
          _NavBarItem(
            icon: Icons.history_outlined,
            activeIcon: Icons.history,
            label: AppStrings.history,
            isSelected: currentIndex == 2,
            onTap: () => onTap(2),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? Colors.white : Colors.white70,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraFloatingButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _CameraFloatingButton({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.cameraGlow,
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: isSelected ? 0.6 : 0.3),
              blurRadius: isSelected ? 20 : 12,
              spreadRadius: isSelected ? 4 : 1,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: const Icon(
          Icons.camera_alt,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
