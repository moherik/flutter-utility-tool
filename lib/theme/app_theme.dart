import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized Design System for EMAS Utility Toolkit.
///
/// Color palette is intentionally minimal (2-3 hues):
///   1. Primary Red  – brand accent, CTAs, active states
///   2. Neutral Grey  – text, borders, backgrounds (light ↔ dark variants)
///
/// Every widget should reference these constants instead of
/// hard-coding hex values so the entire app stays consistent.
class AppTheme {
  // ── Brand Accent ──────────────────────────────────────────────────────
  static const Color primaryColor = Color(0xFFE53935); // Red 600
  static const Color primaryDark = Color(0xFFB71C1C); // Red 900 (pressed)
  static const Color primaryLight = Color(0xFFEF9A9A); // Red 200 (subtle bg)

  // ── Neutral Palette (used for cards, borders, text) ───────────────────
  // Light mode
  static const Color lightBg = Color(0xFFF5F5F5); // Grey 100 – scaffold bg
  static const Color lightCard = Colors.white; // Card surface
  static const Color lightCardAlt = Color(0xFFFAFAFA); // Slightly off-white
  static const Color lightBorder = Color(0xFFE0E0E0); // Grey 300
  static const Color lightTextPrimary = Color(0xFF212121); // Grey 900
  static const Color lightTextSecondary = Color(0xFF757575); // Grey 600

  // Dark mode
  static const Color darkBg = Color(0xFF121212); // Material dark
  static const Color darkCard = Color(0xFF1E1E1E); // Elevation 1
  static const Color darkCardAlt = Color(0xFF2C2C2C); // Elevation 2
  static const Color darkBorder = Color(0xFF424242); // Grey 800
  static const Color darkTextPrimary = Color(0xFFFAFAFA); // Grey 50
  static const Color darkTextSecondary = Color(0xFFBDBDBD); // Grey 400

  // ── Helpers (handy inside widgets) ─────────────────────────────────────
  static Color cardColor(bool isDark) => isDark ? darkCard : lightCard;
  static Color cardAltColor(bool isDark) => isDark ? darkCardAlt : lightCardAlt;
  static Color borderColor(bool isDark) => isDark ? darkBorder : lightBorder;
  static Color textPrimary(bool isDark) => isDark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondary(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;

  // ── Typography ────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(TextTheme base) {
    return GoogleFonts.interTextTheme(base);
  }

  // ── Light Theme ───────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);

    return base.copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightBg,
      cardColor: lightCard,
      dividerColor: lightBorder,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: primaryColor,
        surface: lightCard,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
      ),
      textTheme: _buildTextTheme(base.textTheme).copyWith(
        titleLarge: const TextStyle(color: lightTextPrimary, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        titleMedium: const TextStyle(color: lightTextPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: const TextStyle(color: lightTextPrimary, fontSize: 16),
        bodyMedium: const TextStyle(color: lightTextSecondary, fontSize: 14),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightCard,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: lightTextPrimary),
        titleTextStyle: TextStyle(color: primaryColor, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 1.2),
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: lightBorder, width: 1.0),
        ),
      ),
    );
  }

  // ── Dark Theme ────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.dark);

    return base.copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBg,
      cardColor: darkCard,
      dividerColor: darkBorder,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor,
        surface: darkCard,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
      ),
      textTheme: _buildTextTheme(base.textTheme).copyWith(
        titleLarge: const TextStyle(color: darkTextPrimary, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        titleMedium: const TextStyle(color: darkTextPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: const TextStyle(color: darkTextPrimary, fontSize: 16),
        bodyMedium: const TextStyle(color: darkTextSecondary, fontSize: 14),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCard,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: darkTextPrimary),
        titleTextStyle: TextStyle(color: primaryColor, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 1.2),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: darkBorder, width: 1.0),
        ),
      ),
    );
  }
}
