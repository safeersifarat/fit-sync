import 'package:flutter/material.dart';

const Color kLimeAccent = Color(0xFFCCFF00);

// ── Light mode palette (purple + lime)
const Color kLightPrimary = Color(0xFF7C6AF6); // medium purple
const Color kLightSurface = Color(0xFFF5F1FF); // soft lavender
const Color kLightBackground = Color(0xFFEFEBFF); // deeper lavender bg
const Color kLightCard = Color(0xFFFFFFFF); // pure white cards
const Color kLightTextPri = Color(0xFF1A1528); // dark navy
const Color kLightTextSec = Color(0xFF6B6080); // muted purple-grey

class AppTheme {
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Montserrat',
      brightness: Brightness.light,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: kLightPrimary,
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFE8E2FF),
        onPrimaryContainer: kLightTextPri,
        secondary: kLimeAccent,
        onSecondary: kLightTextPri,
        secondaryContainer: const Color(0xFFEEFFB0),
        onSecondaryContainer: kLightTextPri,
        surface: kLightSurface,
        onSurface: kLightTextPri,
        error: const Color(0xFFFF4757),
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: kLightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: kLightTextPri),
        titleTextStyle: TextStyle(
          color: kLightTextPri,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Montserrat',
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: kLightTextPri,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: kLightTextPri,
        ),
        bodyMedium: TextStyle(fontSize: 14, color: kLightTextSec),
        bodySmall: TextStyle(fontSize: 12, color: kLightTextSec),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(color: kLightTextSec.withValues(alpha: 0.7)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: kLightPrimary.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: kLightPrimary, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: kLightCard,
        elevation: 0,
        shadowColor: kLightPrimary.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: kLightPrimary.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
      ),
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Montserrat',
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kLimeAccent,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
        bodySmall: TextStyle(fontSize: 12, color: Colors.white60),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.35),
        hintStyle: const TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: kLimeAccent, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1A1A),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // Light mode background gradient — soft lavender (matches reference design)
  static BoxDecoration getLightBackgroundDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFEFEBFF), // lavender
          Color(0xFFE8E2FF), // deeper lavender
          Color(0xFFF0ECFF), // soft lavender
        ],
        stops: [0.0, 0.5, 1.0],
      ),
    );
  }

  // Dark mode background gradient
  static BoxDecoration getDarkBackgroundDecoration() {
    return const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(-0.6, -0.8),
        radius: 1.4,
        colors: [Color(0xFF0D2614), Color(0xFF004D40), Color(0xFF00100A)],
        stops: [0.0, 0.6, 1.0],
      ),
    );
  }

  // Get text color based on theme
  static Color getTextColor(BuildContext context, {double opacity = 1.0}) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? Colors.white.withValues(alpha: opacity)
        : kLightTextPri.withValues(alpha: opacity);
  }

  // Get background color based on theme
  static Color getBackgroundColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Colors.black : kLightBackground;
  }

  // Get card color based on theme
  static Color getCardColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? const Color(0xFF1A1A1A) : kLightCard;
  }

  // Get primary accent color based on theme
  static Color getPrimaryColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? kLimeAccent : kLightPrimary;
  }
}
