import 'package:flutter/material.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/core/constants/app_strings.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation (0 - 1s)
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Scale animation (1s - 1.5s)
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOut,
      ),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // Phase 1: Fade in
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();

    // Phase 2: Scale up
    await Future.delayed(const Duration(milliseconds: 1200));
    _scaleController.forward();

    // Phase 3: Navigate
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      _navigateToNext();
    }
  }

  void _navigateToNext() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.splashGradient,
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Eco Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.eco,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                // App Name
                const Text(
                  AppStrings.appName,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                // Tagline
                Text(
                  AppStrings.appTagline,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.85),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
