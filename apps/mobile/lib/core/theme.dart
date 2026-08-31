import 'package:flutter/material.dart';

class AppTheme {
  static const ochre = Color(0xFFC4A35A);
  static const deepBlue = Color(0xFF2C3E6B);
  static const canvasGray = Color(0xFF2A2A2E);
  static const surfaceLight = Color(0xFFF5F3EF);
  static const surfaceDark = Color(0xFF1C1C1E);

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: deepBlue,
        primary: deepBlue,
        secondary: ochre,
        surface: surfaceLight,
      ),
      scaffoldBackgroundColor: surfaceLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceLight,
        foregroundColor: deepBlue,
        elevation: 0,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: deepBlue,
        thumbColor: ochre,
        overlayColor: ochre.withValues(alpha: 0.2),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: deepBlue,
        brightness: Brightness.dark,
        primary: ochre,
        secondary: deepBlue,
        surface: surfaceDark,
      ),
      scaffoldBackgroundColor: surfaceDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: ochre,
        thumbColor: ochre,
      ),
    );
  }
}
