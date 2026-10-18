import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryBlue = Color(0xFF1D4ED8); // Deep Royal Blue
  static const Color accentIndigo = Color(0xFF4F46E5);
  static const Color surfaceBg = Color(0xFFF8FAFC); // Clean Slate
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF0F172A); // Midnight
  static const Color textMuted = Color(0xFF64748B);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningAmber = Color(0xFFF59E0B);

  // Reusable Modern Shadow
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.02),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get hoverShadow => [
        BoxShadow(
          color: primaryBlue.withValues(alpha: 0.16),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: primaryBlue,
      scaffoldBackgroundColor: surfaceBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: primaryBlue,
        side: const BorderSide(color: cardBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textDark,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryBlue, width: 1.8),
        ),
        hintStyle: const TextStyle(
          color: textMuted,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          minimumSize: const Size.fromHeight(50),
          side: const BorderSide(color: primaryBlue, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        indicatorColor: primaryBlue.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: primaryBlue,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textMuted,
          );
        }),
      ),
    );
  }
}
