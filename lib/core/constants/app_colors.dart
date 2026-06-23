import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF60AD5E);
  static const Color primaryDark = Color(0xFF005005);

  // Secondary Colors
  static const Color secondary = Color(0xFF1565C0);
  static const Color secondaryLight = Color(0xFF5E92F3);
  static const Color secondaryDark = Color(0xFF003C8F);

  // Accent
  static const Color accent = Color(0xFF4CAF50);
  static const Color accentLight = Color(0xFF80E27E);

  // Neutrals
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F4F0);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF1C1B1F);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color onSurfaceVariant = Color(0xFF49454F);

  // Semantic
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFF57C00);
  static const Color success = Color(0xFF388E3C);
  static const Color info = Color(0xFF1976D2);

  // AQI Scale Colors
  static const Color aqiGood = Color(0xFF4CAF50);
  static const Color aqiFair = Color(0xFFFFC107);
  static const Color aqiModerate = Color(0xFFFF9800);
  static const Color aqiPoor = Color(0xFFFF5722);
  static const Color aqiVeryPoor = Color(0xFF9C27B0);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF1565C0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Chat bubble colors
  static const Color userBubble = Color(0xFF2E7D32);
  static const Color aiBubble = Color(0xFFE8F5E9);
  static const Color onUserBubble = Color(0xFFFFFFFF);
  static const Color onAiBubble = Color(0xFF1C1B1F);

  /// Get AQI color based on index (1-5)
  static Color getAqiColor(int aqi) {
    switch (aqi) {
      case 1:
        return aqiGood;
      case 2:
        return aqiFair;
      case 3:
        return aqiModerate;
      case 4:
        return aqiPoor;
      case 5:
        return aqiVeryPoor;
      default:
        return aqiGood;
    }
  }
}
