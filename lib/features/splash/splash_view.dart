import 'package:flutter/material.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/core/constants/app_strings.dart';
import 'package:eco/features/splash/splash_viewmodel.dart';
import 'package:eco/features/splash/widgets/scan_illustration.dart';

/// Shared responsive tokens — dipakai WelcomeView juga
/// supaya Hero 'app_name' terbang mulus (ukuran identik).
double heroIconSize(double sw) => (sw * 0.072).clamp(24.0, 36.0);
double heroIconPad(double sw) => (sw * 0.030).clamp(10.0, 16.0);
double heroIconRadius(double sw) => (sw * 0.038).clamp(14.0, 20.0);
double heroFontSize(double sw) => (sw * 0.052).clamp(18.0, 26.0);
double heroIconTextGap(double sw) => (sw * 0.020).clamp(6.0, 12.0);

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  /// Slide UP — semua konten bersamaan, no fade, smooth easeOutExpo
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnim;

  /// Tagline exit — slide UP sebelum Hero flight (no fade)
  late final AnimationController _taglineExitController;
  late final Animation<Offset> _taglineExitSlide;

  final SplashViewModel _viewModel = SplashViewModel();

  @override
  void initState() {
    super.initState();

    // Content slide: kurva easeOutExpo → start cepat, berhenti dengan sangat smooth
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutExpo,
    ));

    // Tagline exit: slide UP + slight fade (sangat subtle, bukan dramatic fade)
    _taglineExitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _taglineExitSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.35),
    ).animate(CurvedAnimation(
      parent: _taglineExitController,
      curve: Curves.easeInCubic,
    ));

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // Langsung mulai slide — no long delay
    await Future.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    _slideController.forward();

    // Hold on screen: cukup 1.5 detik total terasa natural
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    // Tagline slide up keluar → Hero flight bersih
    _taglineExitController.forward();
    await Future.delayed(const Duration(milliseconds: 380));
    if (!mounted) return;

    await _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    final route = await _viewModel.getInitialRoute();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(route);
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _taglineExitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double sw = size.width;
    final double sh = size.height;

    // Hero tokens (identik dengan WelcomeView)
    final double iconSz = heroIconSize(sw);
    final double iconPad = heroIconPad(sw);
    final double iconRadius = heroIconRadius(sw);
    final double nameFontSz = heroFontSize(sw);
    final double iconTextGap = heroIconTextGap(sw);

    // Spacing
    final double illHeroGap = (sh * 0.038).clamp(24.0, 48.0);
    final double heroTaglineGap = (sh * 0.016).clamp(10.0, 20.0);
    final double taglineFontSz = (sw * 0.030).clamp(11.0, 13.5);
    final double taglineHPad = (sw * 0.10).clamp(24.0, 70.0);

    return Scaffold(
      backgroundColor: AppColors.forestNight,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.primary,
        ),
        // Semua konten slide bersama — no fade, easeOutExpo
        child: SlideTransition(
          position: _slideAnim,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// ── Illustration ── Hero ke welcome
              const Hero(
                tag: 'scan_illustration',
                child: ScanIllustration(),
              ),

              SizedBox(height: illHeroGap),

              /// ── Logo + VibEco (2 baris) ── Hero ke welcome
              /// Column: logo container dulu, lalu teks di bawahnya
              Hero(
                tag: 'app_name',
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo (icon container)
                      Container(
                        padding: EdgeInsets.all(iconPad),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(iconRadius),
                        ),
                        child: Icon(
                          Icons.eco,
                          color: Colors.white,
                          size: iconSz,
                        ),
                      ),

                      SizedBox(height: iconTextGap),

                      // VibEco teks
                      Text(
                        AppStrings.appName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: nameFontSz,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: heroTaglineGap),

              /// ── Tagline ── slide keluar sebelum Hero flight (no fade)
              SlideTransition(
                position: _taglineExitSlide,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: taglineHPad),
                  child: Text(
                    AppStrings.appTagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: taglineFontSz,
                      color: Colors.white.withValues(alpha: 0.60),
                      letterSpacing: 0.2,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}