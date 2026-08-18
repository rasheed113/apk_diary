import 'package:flutter/foundation.dart';
import 'app_localization.dart';

/// Language switching is intentionally disabled. The app is English-only.
/// The existing value is kept for compatibility with pages that still consume
/// AppLocalization while the user-facing language layer is removed.
class AppLanguageController {
  AppLanguageController._();

  static final ValueNotifier<AppLanguage> currentLanguage = ValueNotifier<AppLanguage>(AppLanguage.english);

  static Future<void> initialize() async {
    currentLanguage.value = AppLanguage.english;
  }

  static Future<void> setLanguage(AppLanguage language) async {
    currentLanguage.value = AppLanguage.english;
  }

  static void dispose() {
    currentLanguage.dispose();
  }
}
