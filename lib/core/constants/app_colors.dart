import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ══════════════════════════════════════════════════════════════════
  // ── NEW PALETTE ───────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════

  /// #143D60 — Dark Navy (PRIMARY / Main Brand Color)
  static const Color primary = Color(0xFF143D60);
  static const Color primaryDark = Color(0xFF0E2B44);

  /// #27667B — Teal (Secondary)
  static const Color secondary = Color(0xFF27667B);
  static const Color secondaryLight = Color(0xFF3A7F96);

  /// #A0C878 — Green (Accent / Success)
  static const Color accent = Color(0xFFA0C878);
  static const Color accentLight = Color(0xFFB8D99A);
  static const Color accentDark = Color(0xFF88B55E);

  /// #DDEB9D — Light Yellow-Green (Soft Accent / Highlight)
  static const Color highlight = Color(0xFFDDEB9D);

  // ── Backgrounds (Light Mode) ──────────────────────────────────────
  static const Color background = Color(0xFFF7F9F4);
  static const Color lightBackground = Color(0xFFF7F9F4);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F4EC);

  // ── Text Colors ───────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF143D60);
  static const Color textSecondary = Color(0xFF5A7A8A);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textAccent = Color(0xFF27667B);
  static const Color textOnPrimary = Colors.white;
  static const Color textOnAccent = Color(0xFF143D60);

  // Legacy text aliases (used across views)
  static const Color lightTextPrimary = textPrimary;
  static const Color lightTextSecondary = textSecondary;
  static const Color lightTextMuted = textMuted;
  static const Color lightTextAccent = textAccent;
  static const Color onSurface = textPrimary;
  static const Color onSurfaceVariant = textSecondary;
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onBackground = textPrimary;

  // ── Border & Shadow ───────────────────────────────────────────────
  static const Color border = Color(0xFFE2E8F0);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color shadow = Color(0x14143D60); // 8% navy
  static const Color lightShadow = Color(0x14143D60);

  // ── Glass / Overlay ───────────────────────────────────────────────
  static Color glass = Colors.white.withValues(alpha: 0.85);
  static Color glassMedium = Colors.white.withValues(alpha: 0.90);
  static Color glassBorder = const Color(0xFFE2E8F0);
  static Color glassHeavy = Colors.white.withValues(alpha: 0.95);

  // ── Legacy aliases (backward compat) ──────────────────────────────
  static const Color backgroundPrimary = background;
  static const Color backgroundSecondary = Color(0xFFF0F4EC);
  static const Color primaryEmerald = primary;
  static const Color secondaryEmerald = secondary;
  static const Color primaryLight = secondary;
  static const Color secondaryDark = accentDark;
  static const Color secondaryLight2 = accentLight;

  // Light mode legacy aliases
  static const Color lightPrimaryEmerald = primary;
  static const Color lightDarkEmerald = primaryDark;
  static const Color lightSecondaryEmerald = secondary;
  static const Color lightAccentEmerald = accent;
  static const Color lightBackground2 = lightBackground;
  static Color lightGlass = glass;
  static Color lightGlassBorder = glassBorder;
  static Color lightGlassOverlay = primary.withValues(alpha: 0.04);

  // ── Semantic ──────────────────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0x33EF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF22C55E);
  static const Color info = Color(0xFF3B82F6);

  // ── AQI Scale Colors ──────────────────────────────────────────────
  static const Color aqiGood = Color(0xFF4CAF50);
  static const Color aqiFair = Color(0xFFFFC107);
  static const Color aqiModerate = Color(0xFFFF9800);
  static const Color aqiPoor = Color(0xFFFF5722);
  static const Color aqiVeryPoor = Color(0xFF9C27B0);

  // ── Environmental Signal Colors ───────────────────────────────────
  static const Color signalDanger = Color(0xFFEF4444);
  static const Color signalHighWarning = Color(0xFFF97316);
  static const Color signalCaution = Color(0xFFEAB308);
  static const Color signalSafe = Color(0xFF22C55E);
  static const Color signalInstruction = Color(0xFF3B82F6);
  static const Color signalInfo = Color(0xFF64748B);

  // Light mode signal aliases
  static const Color lightSignalSafe = Color(0xFF16A34A);
  static const Color lightSignalAlert = Color(0xFFEAB308);
  static const Color lightSignalWarning = Color(0xFFF97316);
  static const Color lightSignalDanger = Color(0xFFDC2626);
  static const Color lightSignalMandatory = Color(0xFF2563EB);
  static const Color lightSignalInfo = Color(0xFF64748B);

  // ── Chat bubble colors ────────────────────────────────────────────
  static const Color userBubble = Color(0xFF143D60);
  static const Color aiBubble = Color(0xFFF0F4EC);
  static const Color onUserBubble = Colors.white;
  static const Color onAiBubble = Color(0xFF143D60);

  // ── Splash & Welcome (solid, no gradient) ─────────────────────────
  static const Color splashBackground = Color(0xFF143D60);
  static const Color forestNight = Color(0xFF143D60);
  static const Color emerald = Color(0xFF27667B);

  // ── NO GRADIENTS — Solid colors only ──────────────────────────────
  // Legacy gradient references kept as solid-color fallbacks so existing
  // code compiles, but every usage should be replaced with solid color.
  static const LinearGradient welcomeGradient = LinearGradient(
    colors: [Color(0xFF143D60), Color(0xFF143D60)],
  );
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF143D60), Color(0xFF143D60)],
  );
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFA0C878), Color(0xFFA0C878)],
  );
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF143D60), Color(0xFF143D60)],
  );
  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF143D60), Color(0xFF143D60)],
  );
  static const LinearGradient weatherGradient = LinearGradient(
    colors: [Color(0xFF27667B), Color(0xFF27667B)],
  );
  static const LinearGradient cameraGlow = LinearGradient(
    colors: [Color(0xFFA0C878), Color(0xFFA0C878)],
  );
  static const LinearGradient lightEmeraldGradient = LinearGradient(
    colors: [Color(0xFF143D60), Color(0xFF143D60)],
  );
  static const LinearGradient lightAccentGradient = LinearGradient(
    colors: [Color(0xFFA0C878), Color(0xFFA0C878)],
  );
  static const LinearGradient lightSurfaceGradient = LinearGradient(
    colors: [Color(0xFFF7F9F4), Color(0xFFF7F9F4)],
  );

  // ── Compatibility Aliases for Profile UI ─────────────────────────
  static const Color divider = lightBorder;
  static const Color mintGreen = accent;
  static const Color danger = Color(0xFFDC2626);
  // Success alias
  static const Color lightSuccess = Color(0xFF16A34A);
  static const Color lightWarning = Color(0xFFF59E0B);
  static const Color lightDanger = Color(0xFFDC2626);

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
}
