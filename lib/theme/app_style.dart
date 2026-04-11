import 'package:flutter/material.dart';

/// Brand and surfaces tuned for low vision + screenshots (high contrast unchanged in [AccessibilityUtils]).
abstract final class AppStyle {
  static const Color brandTeal = Color(0xFF0F766E);
  static const Color brandTealLight = Color(0xFF14B8A6);
  static const Color brandDeep = Color(0xFF134E4A);
  static const Color surfaceTint = Color(0xFFE0F2F1);
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);

  static const LinearGradient welcomeBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF134E4A), brandTeal, brandTealLight],
    stops: [0.0, 0.45, 1.0],
  );

  static const LinearGradient homeBodyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFECFEFF), Color(0xFFF8FAFC)],
  );

  static const LinearGradient appBarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF115E59), brandTeal],
  );

  static List<BoxShadow> cardShadow(bool highContrast) {
    if (highContrast) return const [];
    return [
      BoxShadow(
        color: const Color(0xFF0F766E).withValues(alpha: 0.08),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ];
  }
}
