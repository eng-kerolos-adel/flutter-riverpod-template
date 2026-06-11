import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  // ─── Brand ─────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6366F1);      // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4338CA);

  static const Color secondary = Color(0xFF10B981);    // Emerald
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF059669);

  // ─── Neutral ───────────────────────────────────────────────────
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // ─── Semantic ──────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ─── Color Schemes ─────────────────────────────────────────────
  static ColorScheme get lightScheme => ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        secondary: secondary,
        error: error,
        surface: Colors.white,
        onSurface: grey900,
        surfaceContainerLowest: grey50,
        surfaceContainerHighest: grey100,
        outline: grey300,
        outlineVariant: grey200,
      );

  static ColorScheme get darkScheme => ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: primaryLight,
        secondary: secondaryLight,
        error: const Color(0xFFF87171),
        surface: const Color(0xFF0F1117),
        onSurface: grey100,
        surfaceContainerLowest: const Color(0xFF161B27),
        surfaceContainerHighest: const Color(0xFF1E2433),
        outline: grey700,
        outlineVariant: grey800,
      );
}
