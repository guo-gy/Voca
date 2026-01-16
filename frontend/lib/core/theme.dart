// Voca 语刻 - Dark Mode Theme
// 深色底色 #121212 + 荧光青 Cyan 高亮

import 'package:flutter/material.dart';

class VocaTheme {
  // Core Colors
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceLight = Color(0xFF2A2A2A);
  
  // Accent - 荧光青 Cyan
  static const Color cyan = Color(0xFF00FFFF);
  static const Color cyanDark = Color(0xFF00BCD4);
  static const Color cyanGlow = Color(0xFF00E5FF);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFB74D);
  
  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF707070);

  // Progress Bar Colors (1/3, 2/3, 3/3)
  static const List<Color> masteryColors = [
    Color(0xFF00BCD4),  // 1/3 - Cyan
    Color(0xFF00E676),  // 2/3 - Green
    Color(0xFFFFD700),  // 3/3 - Gold (Mastered!)
  ];

  // Text Styles (using system fonts for offline compatibility)
  static const TextStyle _baseStyle = TextStyle(
    fontFamily: 'Segoe UI',
    fontFamilyFallback: ['Roboto', 'Helvetica', 'Arial', 'sans-serif'],
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      
      colorScheme: const ColorScheme.dark(
        primary: cyan,
        secondary: cyanDark,
        surface: surface,
        error: error,
        onPrimary: background,
        onSecondary: background,
        onSurface: textPrimary,
        onError: textPrimary,
      ),
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _baseStyle.copyWith(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: cyan),
      ),
      
      // Cards
      cardTheme: CardThemeData(
        color: surface,
        elevation: 8,
        shadowColor: cyan.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Elevated Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cyan,
          foregroundColor: background,
          elevation: 4,
          shadowColor: cyan.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: _baseStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Outlined Buttons (for answer options)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: surfaceLight, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: _baseStyle.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Text Theme
      textTheme: TextTheme(
        // Word display - Large
        displayLarge: _baseStyle.copyWith(
          color: textPrimary,
          fontSize: 48,
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
        ),
        // Phonetic
        displayMedium: _baseStyle.copyWith(
          color: textSecondary,
          fontSize: 18,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.italic,
        ),
        // Titles
        headlineMedium: _baseStyle.copyWith(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        // Body text
        bodyLarge: _baseStyle.copyWith(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.6,
        ),
        bodyMedium: _baseStyle.copyWith(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        // Labels
        labelLarge: _baseStyle.copyWith(
          color: cyan,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
      
      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: cyan,
        linearTrackColor: surfaceLight,
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: surfaceLight,
        thickness: 1,
      ),
    );
  }
}
