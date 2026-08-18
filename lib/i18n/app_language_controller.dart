import 'package:flutter/foundation.dart';

import 'app_localization.dart';

/// Owns the current application language for the app shell.
///
/// Persistence and Settings UI are intentionally outside this controller's
/// first responsibility. This keeps language state separate from profile
/// identity data while allowing MaterialApp to react to language changes.
class AppLanguageController {
  AppLanguageController._();

  static final ValueNotifier<AppLanguage> currentLanguage =
      ValueNotifier<AppLanguage>(AppLanguage.english);

  static void setLanguage(AppLanguage language) {
    if (currentLanguage.value == language) return;
    currentLanguage.value = language;
  }

  static void dispose() {
    currentLanguage.dispose();
  }
}
