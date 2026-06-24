import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eco/features/splash/splash_view.dart';
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
        chatbot: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
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
        },
        scanResult: (context) => ChangeNotifierProvider(
              create: (_) => ScanResultViewModel(),
              child: const ScanResultView(),
            ),
      };
}
