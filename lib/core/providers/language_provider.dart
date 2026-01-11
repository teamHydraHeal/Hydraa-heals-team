import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  Locale _currentLocale = const Locale('en', 'US');
  bool _isInitialized = false;

  Locale get currentLocale => _currentLocale;
  bool get isInitialized => _isInitialized;
  bool get isEnglish => _currentLocale.languageCode == 'en';
  bool get isKhasi => _currentLocale.languageCode == 'kha';

  LanguageProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey) ?? 'en';
      
      _currentLocale = Locale(languageCode);
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to initialize language: $e');
    }
  }

  Future<void> setLanguage(String languageCode) async {
    try {
      _currentLocale = Locale(languageCode);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to set language: $e');
    }
  }

  Future<void> toggleLanguage() async {
    final newLanguageCode = isEnglish ? 'kha' : 'en';
    await setLanguage(newLanguageCode);
  }

  String getLanguageName() {
    return isEnglish ? 'English' : 'Khasi';
  }

  String getLanguageCode() {
    return _currentLocale.languageCode;
  }
}
