import 'package:flutter/material.dart';
import 'theme_manager.dart';

class AppThemeController {
  static final ValueNotifier<AppTheme> currentTheme = ValueNotifier(
    AppTheme.shadowDark,
  );
}
