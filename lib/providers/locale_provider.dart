import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  bool get isIndonesian => _locale.languageCode == 'id';

  LocaleProvider() {
    developer.log('LocaleProvider initialized', name: 'LocaleProvider');
    _loadLocale();
  }

  Locale get locale => _locale;

  Future<void> _loadLocale() async {
    developer.log(
      'Loading locale from SharedPreferences',
      name: 'LocaleProvider',
    );
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode') ?? 'en';
    _locale = Locale(languageCode);
    developer.log('Loaded locale: $languageCode', name: 'LocaleProvider');
    notifyListeners();
  }

  Future<void> setLocale(String languageCode) async {
    developer.log('Setting locale to: $languageCode', name: 'LocaleProvider');
    _locale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
    notifyListeners();
  }

  Future<void> toggleLocale() async {
    final newLanguageCode = isIndonesian ? 'en' : 'id';
    await setLocale(newLanguageCode);
  }
}
