import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/core/constants/app_strings.dart';
import 'package:eco/features/auth/auth_viewmodel.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.splashGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.eco,
                    size: 52,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // App Name
                const Text(
                  AppStrings.appName,
                  style: TextStyle(
                    fontSize: 40,
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
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(flex: 2),

                // Welcome text
                const Text(
                  AppStrings.loginTitle,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.loginSubtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Google Sign-In Button
                Consumer<AuthViewModel>(
                  builder: (context, authVM, child) {
                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: authVM.isLoading
                                ? null
                                : () => _handleSignIn(context, authVM),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.onSurface,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: authVM.isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        AppColors.primary,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Google "G" logo
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'G',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF4285F4),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        AppStrings.signInWithGoogle,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        // Error message
                        if (authVM.errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    authVM.errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignIn(
    BuildContext context,
    AuthViewModel authVM,
  ) async {
    final success = await authVM.signInWithGoogle();
    if (success && context.mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
}
