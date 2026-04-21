import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Brand Colors (Forest Backgrounds & Golden Accents) ──
  static const Color background     = Color(0xFF002623); // Forest very dark
  static const Color cardBackground = Color(0xFF054239); // Forest dark
  static const Color primaryAccent  = Color(0xFFB9A779); // Golden Wheat light
  static const Color primaryDark    = Color(0xFF988561); // Golden Wheat dark
  static const Color secondary      = Color(0xFF428177); // Forest light

  // Text Colors
  static const Color textPrimary   = Color(0xFFEDEBE0); // Golden Wheat off-white
  static const Color textSecondary = Color(0xFFB9A779); // Golden Wheat

  // Status Colors (keep readable against dark bg)
  static const Color danger  = Color(0xFFE53935); // red
  static const Color warning = Color(0xFFF9A825); // amber
  static const Color normal  = Color(0xFF428177); // Forest light replaces generic green
  static const Color closed  = Color(0xFF9E9E9E); // grey

  static ThemeData _base(TextTheme fontTheme) => ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primaryAccent,
      cardColor: cardBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryAccent,
        secondary: secondary,
        surface: cardBackground,
        error: danger,
      ),
      textTheme: fontTheme.copyWith(
        bodyLarge:  fontTheme.bodyLarge?.copyWith(color: textPrimary,   fontSize: 16),
        bodyMedium: fontTheme.bodyMedium?.copyWith(color: textSecondary, fontSize: 14),
        titleLarge: fontTheme.titleLarge?.copyWith(color: textPrimary,   fontSize: 22, fontWeight: FontWeight.bold),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBackground,
        selectedItemColor: primaryAccent,
        unselectedItemColor: textSecondary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        labelStyle: const TextStyle(color: textSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryAccent.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryAccent, width: 1.5),
        ),
      ),
    );

  static ThemeData get themeData   => _base(GoogleFonts.interTextTheme());
  static ThemeData get arabicTheme => _base(GoogleFonts.cairoTextTheme());
}
