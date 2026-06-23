import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:eco/app.dart';
import 'package:eco/features/auth/auth_viewmodel.dart';
import 'package:eco/features/dashboard/dashboard_viewmodel.dart';
import 'package:eco/features/camera/camera_viewmodel.dart';
import 'package:eco/features/camera/scan_result_viewmodel.dart';
import 'package:eco/features/chatbot/chatbot_viewmodel.dart';
import 'package:eco/features/history/history_viewmodel.dart';
import 'package:eco/features/profile/profile_viewmodel.dart';

void main() {
  testWidgets('Splash screen shows app icon', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthViewModel()),
          ChangeNotifierProvider(create: (_) => DashboardViewModel()),
          ChangeNotifierProvider(create: (_) => CameraViewModel()),
          ChangeNotifierProvider(create: (_) => ScanResultViewModel()),
          ChangeNotifierProvider(create: (_) => ChatbotViewModel()),
          ChangeNotifierProvider(create: (_) => HistoryViewModel()),
          ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ],
        child: const EcoApp(),
      ),
    );

    // Verify that the splash screen shows the eco icon.
    expect(find.byIcon(Icons.eco), findsOneWidget);

    // Let the splash screen animations and navigation timers complete to avoid "A Timer is still pending" exception.
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
