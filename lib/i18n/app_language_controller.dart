import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_localization.dart';

/// Owns the current application language for the app shell and persists the
/// user's language choice independently from profile/domain data.
class AppLanguageController {
  AppLanguageController._();

  static const String _storageKey = 'app_language';

  static final ValueNotifier<AppLanguage> currentLanguage =
      ValueNotifier<AppLanguage>(AppLanguage.english);

  static Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    final savedName = preferences.getString(_storageKey);
    if (savedName == null) return;

    final savedLanguage = AppLanguage.values.where((language) => language.name == savedName);
    if (savedLanguage.isNotEmpty) {
      currentLanguage.value = savedLanguage.first;
    }
  }

  static Future<void> setLanguage(AppLanguage language) async {
    if (currentLanguage.value != language) {
      currentLanguage.value = language;
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, language.name);
  }

  static void dispose() {
    currentLanguage.dispose();
  }
}
