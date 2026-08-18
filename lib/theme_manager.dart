import 'package:flutter/material.dart';

enum AppTheme { classicLight, goldLegend, platinumPro, cyberBlue, neonGreen, rubyRed }

class ThemeManager {
  static ThemeData getTheme(AppTheme theme) {
    final schemes = <AppTheme, ColorScheme>{
      AppTheme.classicLight: const ColorScheme.light(primary: Color(0xFF4F6BFF), secondary: Color(0xFF7C5CFF), surface: Color(0xFFF9FBFF)),
      AppTheme.goldLegend: const ColorScheme.light(primary: Color(0xFFD89B18), secondary: Color(0xFFF3C64B), surface: Color(0xFFFFFCF5)),
      AppTheme.platinumPro: const ColorScheme.light(primary: Color(0xFF607D8B), secondary: Color(0xFF90A4AE), surface: Color(0xFFF8FAFB)),
      AppTheme.cyberBlue: const ColorScheme.light(primary: Color(0xFF168BFF), secondary: Color(0xFF49B7FF), surface: Color(0xFFF5FAFF)),
      AppTheme.neonGreen: const ColorScheme.light(primary: Color(0xFF20A83A), secondary: Color(0xFF65D85D), surface: Color(0xFFF6FFF7)),
      AppTheme.rubyRed: const ColorScheme.light(primary: Color(0xFFD92B52), secondary: Color(0xFFFF6B7F), surface: Color(0xFFFFF7F9)),
    };
    final scheme = schemes[theme] ?? schemes[AppTheme.classicLight]!;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: scheme.surface,
      cardColor: Colors.white,
      colorScheme: scheme,
      splashColor: scheme.primary.withValues(alpha: .08),
      highlightColor: scheme.primary.withValues(alpha: .04),
      appBarTheme: AppBarTheme(backgroundColor: scheme.surface, foregroundColor: scheme.primary, elevation: 0, centerTitle: false),
      navigationBarTheme: NavigationBarThemeData(backgroundColor: Colors.white, elevation: 0, indicatorColor: scheme.primary.withValues(alpha: .12)),
      cardTheme: const CardThemeData(elevation: 0, surfaceTintColor: Colors.transparent),
    );
  }
}
