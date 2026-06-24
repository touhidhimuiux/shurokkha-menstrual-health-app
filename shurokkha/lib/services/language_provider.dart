import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'language';
  late Locale _locale;
  bool _isInitialized = false;

  Locale get locale => _locale;
  bool get isInitialized => _isInitialized;
  
  bool get isEnglish => _locale.languageCode == 'en';
  bool get isBengali => _locale.languageCode == 'bn';

  LanguageProvider() {
    _locale = const Locale('bn', 'BD');
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey) ?? 'bn';
      if (languageCode == 'bn') {
        _locale = const Locale('bn', 'BD');
      } else {
        _locale = const Locale('en', 'US');
      }
      _isInitialized = true;
    } catch (e) {
      _locale = const Locale('bn', 'BD');
      _isInitialized = true;
    }
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    try {
      if (languageCode == 'bn') {
        _locale = const Locale('bn', 'BD');
      } else {
        _locale = const Locale('en', 'US');
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      notifyListeners();
    } catch (e) {
      _locale = const Locale('en', 'US');
    }
  }

  Future<void> toggleLanguage() async {
    final newLanguage = isEnglish ? 'bn' : 'en';
    await changeLanguage(newLanguage);
  }
}
