import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eco/features/splash/splash_view.dart';
import 'package:eco/features/welcome/welcome_view.dart';
import 'package:eco/features/auth/login_view.dart';
import 'package:eco/features/home/home_view.dart';
import 'package:eco/features/profile/profile_view.dart';
import 'package:eco/features/chatbot/chatbot_view.dart';
import 'package:eco/features/chatbot/chatbot_viewmodel.dart';
import 'package:eco/features/camera/scan_result_view.dart';
import 'package:eco/features/camera/scan_result_viewmodel.dart';
import 'package:eco/data/models/chatbot_args.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String chatbot = '/chatbot';
  static const String scanResult = '/scan-result';

  /// Semua route pakai PageRouteBuilder tanpa animasi route sendiri.
  /// Hero widgets yang menangani seluruh animasi transisi visual —
  /// hasilnya: perpindahan antar layar terasa instan & seamless.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page = _buildPage(settings);

    // Splash → Welcome: biarkan Hero yang terbang, route instant
    if (settings.name == welcome || settings.name == splash) {
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (_, _, _) => page,
        transitionDuration: const Duration(milliseconds: 520),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (_, animation, _, child) {
          // Hanya Hero yang bergerak — route background tidak animasi
          return child;
        },
      );
    }

    // Layar lainnya: subtle fade transition
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, _, _) => page,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, animation, _, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
          child: child,
        );
      },
    );
  }

  static Widget _buildPage(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return const SplashView();
      case welcome:
        return const WelcomeView();
      case login:
        return const LoginView();
      case home:
        return const HomeView();
      case profile:
        return const ProfileView();
      case chatbot:
        final args = settings.arguments;
        ChatbotArgs? chatbotArgs;
        if (args is ChatbotArgs) {
          chatbotArgs = args;
        } else if (args is String) {
          chatbotArgs = ChatbotArgs(sessionId: args);
        }
        return ChangeNotifierProvider(
          create: (_) => ChatbotViewModel(args: chatbotArgs),
          child: const ChatbotView(),
        );
      case scanResult:
        return ChangeNotifierProvider(
          create: (_) => ScanResultViewModel(),
          child: const ScanResultView(),
        );
      default:
        return const SplashView();
    }
  }

  /// Tetap sediakan routes map untuk kompatibilitas jika dipakai di tempat lain
  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashView(),
        welcome: (context) => const WelcomeView(),
        login: (context) => const LoginView(),
        home: (context) => const HomeView(),
        profile: (context) => const ProfileView(),
      };
}