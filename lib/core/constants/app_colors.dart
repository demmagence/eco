import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Forest gradient — khusus Splash & Welcome
  static const Color forestNight = Color(0xFF06241B);
  static const Color emerald = Color(0xFF0F4D3A);

  static const LinearGradient welcomeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [forestNight, emerald],
  );

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

  // ── Environmental Signal Colors ───────────────────────────────────
  static const Color signalDanger = Color(0xFFEF4444);       // Merah — Bahaya
  static const Color signalHighWarning = Color(0xFFF97316);   // Oranye — Peringatan Tinggi
  static const Color signalCaution = Color(0xFFEAB308);       // Kuning — Waspada
  static const Color signalSafe = Color(0xFF22C55E);          // Hijau — Aman
  static const Color signalInstruction = Color(0xFF3B82F6);   // Biru — Instruksi Khusus
  static const Color signalInfo = Colors.white;               // Putih — Informasi Umum

  // ══════════════════════════════════════════════════════════════════
  // ── LIGHT MODE PREMIUM PALETTE ────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════

  // Primary backgrounds
  static const Color lightBackground = Color(0xFFF6FAF8);
  static const Color lightCardBackground = Color(0xFFFFFFFF);

  // Emerald palette
  static const Color lightPrimaryEmerald = Color(0xFF0F4D3A);
  static const Color lightDarkEmerald = Color(0xFF06241B);
  static const Color lightSecondaryEmerald = Color(0xFF1A6B53);
  static const Color lightAccentEmerald = Color(0xFF34D399);

  // Semantic (light mode)
  static const Color lightSuccess = Color(0xFF16A34A);
  static const Color lightWarning = Color(0xFFF59E0B);
  static const Color lightDanger = Color(0xFFDC2626);

  // Border & Shadow (light mode)
  static const Color lightBorder = Color(0xFFE6F4EE);
  static const Color lightShadow = Color(0x140F4D3A); // rgba(15,77,58,0.08)

  // Text (light mode)
  static const Color lightTextPrimary = Color(0xFF06241B);
  static const Color lightTextSecondary = Color(0xFF4A6B5D);
  static const Color lightTextMuted = Color(0xFF8BA69A);
  static const Color lightTextAccent = Color(0xFF0F4D3A);

  // Glass / Surface (light mode)
  static Color lightGlass = Colors.white.withValues(alpha: 0.85);
  static Color lightGlassBorder = const Color(0xFFE6F4EE);
  static Color lightGlassOverlay = const Color(0xFF0F4D3A).withValues(alpha: 0.04);

  // ── Signal Colors (Light Mode Specific) ──────────────────────────
  static const Color lightSignalSafe = Color(0xFF16A34A);
  static const Color lightSignalAlert = Color(0xFFEAB308);
  static const Color lightSignalWarning = Color(0xFFF97316);
  static const Color lightSignalDanger = Color(0xFFDC2626);
  static const Color lightSignalMandatory = Color(0xFF2563EB);
  static const Color lightSignalInfo = Color(0xFF64748B);

  // ── Light mode gradients ──────────────────────────────────────────
  static const LinearGradient lightEmeraldGradient = LinearGradient(
    colors: [Color(0xFF0F4D3A), Color(0xFF1A6B53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightAccentGradient = LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF6EE7B7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightSurfaceGradient = LinearGradient(
    colors: [Color(0xFFF6FAF8), Color(0xFFEDF7F2)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Gradients ─────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryEmerald, secondaryEmerald],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF06241B), Color(0xFF0F4D3A), Color(0xFF1A6B53)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF06241B), Color(0xFF0F4D3A), Color(0xFF1A6B53)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient weatherGradient = LinearGradient(
    colors: [Color(0xFF0F4D3A), Color(0xFF1A6B53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cameraGlow = LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Chat bubble colors
  static const Color userBubble = Color(0xFF0F4D3A);
  static const Color aiBubble = Color(0xFF1A6B53);
  static const Color onUserBubble = Colors.white;
  static const Color onAiBubble = Colors.white;

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

  /// Get environmental signal color by level
  static Color getSignalColor(String level) {
    switch (level.toLowerCase()) {
      case 'bahaya':
        return signalDanger;
      case 'peringatan tinggi':
      case 'peringatan':
        return signalHighWarning;
      case 'waspada':
        return signalCaution;
      case 'aman':
        return signalSafe;
      case 'instruksi':
      case 'instruksi khusus':
        return signalInstruction;
      default:
        return signalInfo;
    }
  }

  /// Get light mode signal color by level
  static Color getLightSignalColor(String level) {
    switch (level.toLowerCase()) {
      case 'bahaya':
        return lightSignalDanger;
      case 'peringatan tinggi':
      case 'peringatan':
        return lightSignalWarning;
      case 'waspada':
        return lightSignalAlert;
      case 'aman':
        return lightSignalSafe;
      case 'instruksi':
      case 'instruksi khusus':
        return lightSignalMandatory;
      default:
        return lightSignalInfo;
    }
  }
  // ── Compatibility Aliases for Profile UI ─────────────────────────
  static const Color divider = lightBorder;
  static const Color shadow = lightShadow;
  static const Color mintGreen = lightAccentEmerald;
  static const Color danger = lightDanger;
}
