import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';

class LanguageService extends ChangeNotifier {
  String _lang = 'ar'; // default Arabic

  String get lang => _lang;
  bool get isArabic => _lang == 'ar';
  TextDirection get direction =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  void setLanguage(String lang) {
    if (_lang == lang) return;
    _lang = lang;
    notifyListeners();
  }

  void toggle() {
    _lang = isArabic ? 'en' : 'ar';
    notifyListeners();
  }

  /// Translate a key to the current language
  String t(String key) => AppStrings.get(key, _lang);
}
