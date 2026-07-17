import 'package:flutter/material.dart';

enum AppTheme {
  shadowDark,
  goldLegend,
  platinumPro,
  cyberBlue,
  neonGreen,
}

class ThemeManager {
  static ThemeData getTheme(AppTheme theme) {
    switch (theme) {

      case AppTheme.shadowDark:
        return ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.deepPurpleAccent,
            secondary: Colors.purpleAccent,
          ),
        );

      case AppTheme.goldLegend:
        return ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFFD700),
            secondary: Colors.orangeAccent,
          ),
        );

      case AppTheme.platinumPro:
        return ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.blueGrey,
            secondary: Colors.grey,
          ),
        );

      case AppTheme.cyberBlue:
        return ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.cyanAccent,
            secondary: Colors.blueAccent,
          ),
        );

      case AppTheme.neonGreen:
        return ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.greenAccent,
            secondary: Colors.lightGreenAccent,
          ),
        );
    }
  }
}
