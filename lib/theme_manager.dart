import 'package:flutter/material.dart';

enum AppTheme {
  classicLight,
  shadowDark,
  goldLegend,
  platinumPro,
  cyberBlue,
  neonGreen,
  rubyRed,
}

class ThemeManager {
  static ThemeData getTheme(AppTheme theme) {
    switch (theme) {
      case AppTheme.classicLight:
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFF5F6FA),
          cardColor: Colors.white,
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF3F51B5),
            secondary: Color(0xFF5C6BC0),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF3F51B5),
            foregroundColor: Colors.white,
            elevation: 4,
          ),
        );

      case AppTheme.shadowDark:
        return ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: const Color(0xFF0A0A0A),
          cardColor: const Color(0xFF1A1A1A),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF9C27B0),
            secondary: Color(0xFFE040FB),
          ),
        );

      case AppTheme.goldLegend:
        return ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: const Color(0xFF090909),
          cardColor: const Color(0xFF1A1400),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFFD700),
            secondary: Color(0xFFFFB300),
          ),
        );

      case AppTheme.platinumPro:
        return ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: const Color(0xFF101010),
          cardColor: const Color(0xFF202020),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFE5E4E2),
            secondary: Color(0xFFBFC5CA),
          ),
        );

      case AppTheme.cyberBlue:
        return ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: const Color(0xFF050A14),
          cardColor: const Color(0xFF101C30),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00E5FF),
            secondary: Color(0xFF2979FF),
          ),
        );

      case AppTheme.neonGreen:
        return ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: const Color(0xFF071107),
          cardColor: const Color(0xFF102010),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00FF66),
            secondary: Color(0xFF76FF03),
          ),
        );

      case AppTheme.rubyRed:
        return ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: const Color(0xFF120606),
          cardColor: const Color(0xFF2A1010),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFF1744),
            secondary: Color(0xFFFF5252),
          ),
        );
    }
  }
}
