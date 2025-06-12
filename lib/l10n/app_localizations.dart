import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'app_title': 'Dicoding Story App',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'logout': 'Logout',
      'stories': 'Stories',
      'add_story': 'Add Story',
      'description': 'Description',
      'upload': 'Upload',
      'no_data': 'No data available',
      'error': 'An error occurred',
      'loading': 'Loading...',
      'story_app': 'Story App',
      'please_login': 'Please login to continue',
      'please_register': 'Please register if you don\'t have an account',
      'language': 'Language',
    },
    'id': {
      'app_title': 'Aplikasi Cerita Dicoding',
      'login': 'Masuk',
      'register': 'Daftar',
      'email': 'Email',
      'story_app': 'Aplikasi Cerita',
      'please_login': 'Silakan masuk untuk melanjutkan',
      'please_register': 'Silakan daftar jika belum punya akun',
      'language': 'Bahasa',
      'password': 'Kata Sandi',
      'logout': 'Keluar',
      'stories': 'Cerita',
      'add_story': 'Tambah Cerita',
      'description': 'Deskripsi',
      'upload': 'Unggah',
      'no_data': 'Tidak ada data',
      'error': 'Terjadi kesalahan',
      'loading': 'Memuat...',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'id'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
