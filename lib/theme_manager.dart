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
          scaffoldBackgroundColor: const Color(0xFF050505),
          cardColor: const Color(0xFF2B2100),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFFE55C),
            secondary: Color(0xFFFFEA00),
          ),
        );

      case AppTheme.platinumPro:
        return ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: const Color(0xFF101010),
          cardColor: const Color(0xFF2A2A2A),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFFFFFF),
            secondary: Color(0xFFDADADA),
          ),
        );

      case AppTheme.cyberBlue:
        return ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: const Color(0xFF030A15),
          cardColor: const Color(0xFF0A223A),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00F0FF),
            secondary: Color(0xFF42A5F5),
          ),
        );

      case AppTheme.neonGreen:
        return ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: const Color(0xFF071107),
          cardColor: const Color(0xFF102010),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF39FF14),
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
