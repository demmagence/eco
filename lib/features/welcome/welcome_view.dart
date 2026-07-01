import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/core/constants/app_strings.dart';
import 'package:eco/features/auth/auth_viewmodel.dart';


class WelcomeView extends StatefulWidget {
  final int initialPage;
  final int initialAuthTab;

  const WelcomeView({
    super.key,
    this.initialPage = 0,
    this.initialAuthTab = 0,
  });

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  late final PageController _pageController;
  int _currentPage = 0;

  // Tab state for Auth Page (0 = Login, 1 = Register)
  int _activeAuthTab = 0;

  // Controllers
  final _loginUsernameCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();
  bool _obscureLoginPass = true;

  final _regNameCtrl = TextEditingController();
  final _regUsernameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  final _regConfirmPassCtrl = TextEditingController();
  bool _obscureRegPass = true;
  bool _obscureRegConfirm = true;

  final _formKeyLogin = GlobalKey<FormState>();
  final _formKeyRegister = GlobalKey<FormState>();

  AuthViewModel? _authVM;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _activeAuthTab = widget.initialAuthTab;
    _pageController = PageController(initialPage: widget.initialPage);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = context.read<AuthViewModel>();
      _authVM = authVM..addListener(_onAuthChanged);
      authVM.initialize();
    });
  }

  void _onAuthChanged() {
    final authVM = _authVM;
    if (authVM != null && authVM.isAuthenticated && mounted) {
      authVM.removeListener(_onAuthChanged);
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _loginUsernameCtrl.dispose();
    _loginPassCtrl.dispose();
    _regNameCtrl.dispose();
    _regUsernameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPassCtrl.dispose();
    _regConfirmPassCtrl.dispose();
    _authVM?.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentPage == 0 ? AppColors.primary : AppColors.background,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe, button-only navigation
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: [
          _buildStartPage(),
          _buildOnboardingPage1(),
          _buildOnboardingPage2(),
          _buildAuthPage(),
        ],
      ),
    );
  }

  // ─── PAGE 0: START PAGE ("SAVE THE PLANET") ──────────────────────────────────
  Widget _buildStartPage() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            const Spacer(),
            // Leaf Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: Colors.white,
                size: 64,
              ),
            ),
            const SizedBox(height: 32),
            // Title
            const Text(
              'SAVE\nTHE\nPLANET',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                height: 1.1,
              ),
            ),
            const Spacer(),
            // Start Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Start',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── PAGE 1: ONBOARDING PAGE 1 ───────────────────────────────────────────────
  Widget _buildOnboardingPage1() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            const Spacer(),
            // Illustration
            _buildIllustration(
              icon: Icons.air_rounded,
              color: AppColors.primary,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            ),
            const SizedBox(height: 48),
            // Content
            const Text(
              'Pantau Kualitas Udara',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Dapatkan informasi real-time mengenai kualitas udara, suhu, dan kelembapan di sekitarmu dengan mudah.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            const Spacer(),
            // Page Indicators
            _buildIndicators(0),
            const SizedBox(height: 24),
            // Next Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Selanjutnya',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── PAGE 2: ONBOARDING PAGE 2 ───────────────────────────────────────────────
  Widget _buildOnboardingPage2() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            const Spacer(),
            // Illustration
            _buildIllustration(
              icon: Icons.psychology_rounded,
              color: AppColors.accent,
              backgroundColor: AppColors.accent.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 48),
            // Content
            const Text(
              'Rekomendasi AI',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Dapatkan saran kesehatan dan aktivitas yang disesuaikan oleh AI untuk kondisi lingkungan sekitarmu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            const Spacer(),
            // Page Indicators
            _buildIndicators(1),
            const SizedBox(height: 24),
            // Next Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Selanjutnya',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── PAGE 3: UNIFIED AUTH PAGE ──────────────────────────────────────────────
  Widget _buildAuthPage() {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          color: AppColors.primary,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        AppStrings.appName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Active Form
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _activeAuthTab == 0 ? _buildLoginForm(authVM) : _buildRegisterForm(authVM),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── LOGIN FORM ────────────────────────────────────────────────────────────
  Widget _buildLoginForm(AuthViewModel authVM) {
    return Form(
      key: _formKeyLogin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Username
          _buildInputField(
            controller: _loginUsernameCtrl,
            label: 'USERNAME',
            hint: 'Masukkan username Anda',
            icon: Icons.person_outline_rounded,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Username wajib diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Password
          _buildInputField(
            controller: _loginPassCtrl,
            label: 'PASSWORD',
            hint: 'Masukkan password Anda',
            icon: Icons.lock_outline_rounded,
            obscure: _obscureLoginPass,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureLoginPass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppColors.textMuted,
                size: 20,
              ),
              onPressed: () => setState(() => _obscureLoginPass = !_obscureLoginPass),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Password wajib diisi';
              }
              return null;
            },
          ),

          // Error Message
          if (authVM.errorMessage != null) ...[
            const SizedBox(height: 16),
            _buildErrorMessage(authVM.errorMessage!),
          ],

          const SizedBox(height: 32),

          // Login Button
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: authVM.isLoading ? null : () => _submitLogin(authVM),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: authVM.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              setState(() {
                _activeAuthTab = 1;
                authVM.clearError();
              });
            },
            child: const Text.rich(
              TextSpan(
                text: 'Belum punya akun? ',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: 'Daftar Sekarang',
                    style: TextStyle(
                      color: AppColors.accentDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ─── REGISTER FORM ─────────────────────────────────────────────────────────
  Widget _buildRegisterForm(AuthViewModel authVM) {
    return Form(
      key: _formKeyRegister,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Full Name
          _buildInputField(
            controller: _regNameCtrl,
            label: 'NAMA LENGKAP',
            hint: 'Nama lengkap Anda',
            icon: Icons.badge_outlined,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Nama lengkap wajib diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Username
          _buildInputField(
            controller: _regUsernameCtrl,
            label: 'USERNAME',
            hint: 'Pilih username',
            icon: Icons.alternate_email_rounded,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Username wajib diisi';
              }
              if (v.trim().length < 3) {
                return 'Username minimal 3 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Email
          _buildInputField(
            controller: _regEmailCtrl,
            label: 'EMAIL (OPSIONAL)',
            hint: 'Alamat email Anda',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          // Password
          _buildInputField(
            controller: _regPassCtrl,
            label: 'PASSWORD',
            hint: 'Minimal 6 karakter',
            icon: Icons.lock_outline_rounded,
            obscure: _obscureRegPass,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureRegPass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppColors.textMuted,
                size: 20,
              ),
              onPressed: () => setState(() => _obscureRegPass = !_obscureRegPass),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Password wajib diisi';
              }
              if (v.length < 6) {
                return 'Password minimal 6 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Confirm Password
          _buildInputField(
            controller: _regConfirmPassCtrl,
            label: 'KONFIRMASI PASSWORD',
            hint: 'Ulangi password Anda',
            icon: Icons.lock_reset_rounded,
            obscure: _obscureRegConfirm,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureRegConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppColors.textMuted,
                size: 20,
              ),
              onPressed: () => setState(() => _obscureRegConfirm = !_obscureRegConfirm),
            ),
            validator: (v) {
              if (v != _regPassCtrl.text) {
                return 'Password tidak cocok';
              }
              return null;
            },
          ),

          // Error Message
          if (authVM.errorMessage != null) ...[
            const SizedBox(height: 16),
            _buildErrorMessage(authVM.errorMessage!),
          ],

          const SizedBox(height: 24),

          // Terms and Conditions Notice
          const Text(
            'Dengan mendaftar, Anda menyetujui Ketentuan Layanan dan Kebijakan Privasi Eco.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 24),

          // Register Button
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: authVM.isLoading ? null : () => _submitRegister(authVM),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: authVM.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text(
                      'Daftar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              setState(() {
                _activeAuthTab = 0;
                authVM.clearError();
              });
            },
            child: const Text.rich(
              TextSpan(
                text: 'Sudah punya akun? ',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: 'Login Sekarang',
                    style: TextStyle(
                      color: AppColors.accentDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ─── HELPER WIDGETS ─────────────────────────────────────────────────────────

  Widget _buildIllustration({
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer circle
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
            ),
          ),
          // Icon Container
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(
              icon,
              color: color,
              size: 48,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicators(int activeIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        2,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == activeIndex ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == activeIndex ? AppColors.primary : AppColors.textMuted.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: AppColors.textMuted),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _submitLogin(AuthViewModel authVM) {
    if (!_formKeyLogin.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    authVM.signIn(
      _loginUsernameCtrl.text.trim(),
      _loginPassCtrl.text,
    );
  }

  Future<void> _submitRegister(AuthViewModel authVM) async {
    if (!_formKeyRegister.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    await authVM.signUp(
      username: _regUsernameCtrl.text.trim(),
      password: _regPassCtrl.text,
      displayName: _regNameCtrl.text.trim(),
      email: _regEmailCtrl.text.trim().isEmpty ? null : _regEmailCtrl.text.trim(),
    );
  }
}