import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:eco/core/constants/app_colors.dart';
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
            backgroundColor: AppColors.background,
            body: IndexedStack(
              index: homeVM.currentIndex,
              children: const [
                DashboardView(),
                CameraView(),
                HistoryView(),
              ],
            ),
            bottomNavigationBar: _AnchoredBottomBar(
              currentIndex: homeVM.currentIndex,
              onTap: (index) {
                HapticFeedback.mediumImpact();
                homeVM.setIndex(index);
                if (index == 2) {
                  context.read<HistoryViewModel>().loadHistory();
                }
              },
            ),
          );
        },
      ),
    );
  }
}

/// Standard anchored bottom navigation bar with a floating center camera button.
class _AnchoredBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _AnchoredBottomBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Navbar Background Container
        Container(
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Home Tab
                  _NavBarItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'Home',
                    isSelected: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),

                  // Placeholder for the floating center button
                  const SizedBox(width: 72),

                  // History Tab
                  _NavBarItem(
                    icon: Icons.history_outlined,
                    activeIcon: Icons.history,
                    label: 'Riwayat',
                    isSelected: currentIndex == 2,
                    onTap: () => onTap(2),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Floating Center Camera Button
        Positioned(
          top: -24,
          left: 0,
          right: 0,
          child: Center(
            child: _CameraCenterButton(
              isSelected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
          ),
        ),
      ],
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
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? Colors.white : Colors.white60,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraCenterButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _CameraCenterButton({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.primary,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.camera_alt_rounded,
          color: isSelected ? AppColors.accent : AppColors.primary,
          size: 28,
        ),
      ),
    );
  }
}
