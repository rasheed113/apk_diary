import 'package:flutter/material.dart';

enum AppTheme { classicLight, shadowDark, goldLegend, platinumPro, cyberBlue, neonGreen, rubyRed }

class ThemeManager {
  static ThemeData getTheme(AppTheme theme) {
    final schemes = <AppTheme, ColorScheme>{
      AppTheme.classicLight: const ColorScheme.light(primary: Color(0xFF3F51B5), secondary: Color(0xFF5C6BC0)),
      AppTheme.shadowDark: const ColorScheme.light(primary: Color(0xFF9C27B0), secondary: Color(0xFFE040FB)),
      AppTheme.goldLegend: const ColorScheme.light(primary: Color(0xFFE0A800), secondary: Color(0xFFFFC107)),
      AppTheme.platinumPro: const ColorScheme.light(primary: Color(0xFF607080), secondary: Color(0xFF90A4AE)),
      AppTheme.cyberBlue: const ColorScheme.light(primary: Color(0xFF008CFF), secondary: Color(0xFF42A5F5)),
      AppTheme.neonGreen: const ColorScheme.light(primary: Color(0xFF159B00), secondary: Color(0xFF39C91F)),
      AppTheme.rubyRed: const ColorScheme.light(primary: Color(0xFFE31845), secondary: Color(0xFFFF5252)),
    };
    final scheme = schemes[theme]!;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF7F9FC),
      cardColor: Colors.white,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(backgroundColor: scheme.primary, foregroundColor: Colors.white, elevation: 0),
      navigationBarTheme: NavigationBarThemeData(backgroundColor: Colors.white, elevation: 0, indicatorColor: scheme.primary.withValues(alpha: .12)),
    );
  }
}
