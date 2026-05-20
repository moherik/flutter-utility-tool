import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized design system for EMAS Utility Toolkit.
///
/// Clean, minimal palette:
///   • Indigo  – brand accent, CTAs, active states
///   • Slate     – backgrounds, text, borders (light ↔ dark)
///   • Teal      – secondary accent, success / info states
class AppTheme {
  // ── Brand Colors ──────────────────────────────────────────────────────
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFFEEF2FF);
  static const Color secondaryColor = Color(0xFF0F172A);
  static const Color tertiaryColor = Color(0xFF14B8A6);
  static const Color neutralColor = Color(0xFF94A3B8);
  static const Color bodyTextColor = Color(0xFF475569);

  // ── Light Palette ─────────────────────────────────────────────────────
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardAlt = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // ── Dark Palette ──────────────────────────────────────────────────────
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkCardAlt = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  static const double cardRadius = 16.0;
  static const double controlRadius = 12.0;

  // ── Helpers ───────────────────────────────────────────────────────────
  static Color cardColor(bool isDark) => isDark ? darkCard : lightCard;
  static Color cardAltColor(bool isDark) => isDark ? darkCardAlt : lightCardAlt;
  static Color borderColor(bool isDark) => isDark ? darkBorder : lightBorder;
  static Color textPrimary(bool isDark) =>
      isDark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondary(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;

  static Color statusInfo(bool isDark) => tertiaryColor;
  static Color statusSuccess(bool isDark) => tertiaryColor;
  static Color statusWarning(bool isDark) => const Color(0xFFF59E0B);
  static Color statusDanger(bool isDark) => const Color(0xFFEF4444);

  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentViolet = Color(0xFF8B5CF6);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentRose = Color(0xFFF43F5E);

  static Color categoryAccent(String category) {
    switch (category) {
      case 'math_calc':
        return primaryColor;
      case 'measure_sensor':
        return tertiaryColor;
      case 'graphic_text':
        return accentViolet;
      case 'device_time':
        return accentBlue;
      default:
        return neutralColor;
    }
  }

  static String categoryLabel(String category, String lang) {
    switch (category) {
      case 'math_calc':
        return lang == 'id' ? 'Kalkulator & Angka' : 'Math & Numbers';
      case 'measure_sensor':
        return lang == 'id' ? 'Sensor & Pengukur' : 'Sensors & Measurement';
      case 'graphic_text':
        return lang == 'id' ? 'Teks & Grafik' : 'Text & Graphics';
      case 'device_time':
        return lang == 'id' ? 'Perangkat & Waktu' : 'Device & Time';
      default:
        return lang == 'id' ? 'Lainnya' : 'Other';
    }
  }

  static IconData categoryIcon(String category) {
    switch (category) {
      case 'math_calc':
        return Icons.calculate_outlined;
      case 'measure_sensor':
        return Icons.sensors_outlined;
      case 'graphic_text':
        return Icons.palette_outlined;
      case 'device_time':
        return Icons.devices_outlined;
      default:
        return Icons.apps_rounded;
    }
  }

  static List<BoxShadow> cardShadow(bool isDark) {
    if (isDark) return const [];
    return [
      BoxShadow(
        color: const Color(0xFF0F172A).withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static BoxDecoration surfaceDecoration(bool isDark, {Color? color}) {
    return BoxDecoration(
      color: color ?? cardColor(isDark),
      borderRadius: BorderRadius.circular(cardRadius),
      border: Border.all(
        color: borderColor(isDark).withValues(alpha: isDark ? 0.6 : 0.8),
      ),
      boxShadow: cardShadow(isDark),
    );
  }

  // ── Typography ────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(TextTheme base, bool isDark) {
    final primary = textPrimary(isDark);
    final secondary = textSecondary(isDark);
    return GoogleFonts.plusJakartaSansTextTheme(base).apply(
      bodyColor: secondary,
      displayColor: primary,
    );
  }

  static OutlinedBorder get controlShape => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(controlRadius),
  );

  static ButtonStyle _filledButtonStyle({Color? background}) {
    return ElevatedButton.styleFrom(
      backgroundColor: background ?? primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      shape: controlShape,
    );
  }

  static ButtonStyle _outlinedButtonStyle(bool isDark) {
    return OutlinedButton.styleFrom(
      foregroundColor: textPrimary(isDark),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      side: BorderSide(color: borderColor(isDark)),
      shape: controlShape,
    );
  }

  static InputDecorationTheme _inputDecorationTheme(bool isDark) {
    return InputDecorationTheme(
      filled: true,
      fillColor: cardAltColor(isDark),
      hintStyle: TextStyle(color: textSecondary(isDark)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(controlRadius),
        borderSide: BorderSide(color: borderColor(isDark)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(controlRadius),
        borderSide: BorderSide(color: borderColor(isDark)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(controlRadius),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
    );
  }

  static ChipThemeData _chipTheme(bool isDark) {
    return ChipThemeData(
      backgroundColor: cardAltColor(isDark),
      selectedColor: primaryColor,
      disabledColor: cardAltColor(isDark),
      labelStyle: TextStyle(
        color: textSecondary(isDark),
        fontWeight: FontWeight.w600,
      ),
      secondaryLabelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      checkmarkColor: Colors.white,
      side: BorderSide(color: borderColor(isDark)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(controlRadius),
      ),
    );
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
        onPrimary: Colors.white,
        secondary: tertiaryColor,
        onSecondary: Colors.white,
        tertiary: tertiaryColor,
        surface: lightCard,
        onSurface: lightTextPrimary,
        outline: lightBorder,
      ),
      textTheme: _buildTextTheme(base.textTheme, false).copyWith(
        headlineLarge: const TextStyle(
          color: lightTextPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: const TextStyle(
          color: lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleMedium: const TextStyle(
          color: lightTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: const TextStyle(
          color: bodyTextColor,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: const TextStyle(
          color: bodyTextColor,
          fontSize: 14,
          height: 1.5,
        ),
        labelLarge: const TextStyle(
          color: lightTextPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: lightTextPrimary),
        titleTextStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: lightBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: _filledButtonStyle()),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _outlinedButtonStyle(false),
      ),
      inputDecorationTheme: _inputDecorationTheme(false),
      chipTheme: _chipTheme(false),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: lightCardAlt,
        thumbColor: primaryColor,
        overlayColor: primaryColor.withValues(alpha: 0.12),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primaryColor
              : neutralColor,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primaryLight
              : lightCardAlt,
        ),
      ),
      dividerTheme: const DividerThemeData(color: lightBorder, thickness: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightCard,
        indicatorColor: primaryLight,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: lightTextSecondary,
          );
        }),
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
        onPrimary: Colors.white,
        secondary: tertiaryColor,
        onSecondary: Colors.white,
        tertiary: tertiaryColor,
        surface: darkCard,
        onSurface: darkTextPrimary,
        outline: darkBorder,
      ),
      textTheme: _buildTextTheme(base.textTheme, true).copyWith(
        headlineLarge: const TextStyle(
          color: darkTextPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: const TextStyle(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleMedium: const TextStyle(
          color: darkTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: const TextStyle(
          color: darkTextSecondary,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: const TextStyle(
          color: darkTextSecondary,
          fontSize: 14,
          height: 1.5,
        ),
        labelLarge: const TextStyle(
          color: darkTextPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: darkTextPrimary),
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: darkBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: _filledButtonStyle()),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _outlinedButtonStyle(true),
      ),
      inputDecorationTheme: _inputDecorationTheme(true),
      chipTheme: _chipTheme(true),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: darkCardAlt,
        thumbColor: primaryColor,
        overlayColor: primaryColor.withValues(alpha: 0.16),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primaryColor
              : darkTextSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primaryDark
              : darkCardAlt,
        ),
      ),
      dividerTheme: const DividerThemeData(color: darkBorder, thickness: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkCard,
        indicatorColor: primaryDark.withValues(alpha: 0.4),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: darkTextSecondary,
          );
        }),
      ),
    );
  }
}
