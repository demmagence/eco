import 'package:flutter/material.dart';
import 'package:eco/features/splash/splash_view.dart';
import 'package:eco/features/auth/login_view.dart';
import 'package:eco/features/home/home_view.dart';
import 'package:eco/features/profile/profile_view.dart';
import 'package:eco/features/chatbot/chatbot_view.dart';
import 'package:eco/features/camera/scan_result_view.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String chatbot = '/chatbot';
  static const String scanResult = '/scan-result';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashView(),
        login: (context) => const LoginView(),
        home: (context) => const HomeView(),
        profile: (context) => const ProfileView(),
        chatbot: (context) => const ChatbotView(),
        scanResult: (context) => const ScanResultView(),
      };
}
