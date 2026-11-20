import 'dart:ui';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's language choice, mirroring the portal's
/// `preferredLanguage` behaviour. Default is English.
class LanguageService {
  static const _prefKey = 'preferredLanguage';
  static const english = Locale('en');
  static const somali = Locale('so');

  /// The locale to start the app with.
  static Future<Locale> savedLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKey) == 'so' ? somali : english;
  }

  static bool get isSomali => Get.locale?.languageCode == 'so';

  /// Switch language app-wide and remember the choice.
  static Future<void> toggle() async {
    var next = isSomali ? english : somali;
    Get.updateLocale(next);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, next.languageCode);
  }
}
