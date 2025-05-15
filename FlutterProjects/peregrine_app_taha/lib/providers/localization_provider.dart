import 'package:flutter/material.dart';
import 'package:peregrine_app_taha/utils/app_localizations.dart';

class LocalizationProvider with ChangeNotifier {
  Locale _locale = const Locale('ar');
  
  Locale get locale => _locale;
  
  LocalizationProvider() {
    _loadLocale();
  }
  
  // Load locale from shared preferences
  Future<void> _loadLocale() async {
    _locale = await AppLocalizations.load();
    notifyListeners();
  }
  
  // Set locale and save preference
  Future<void> setLocale(Locale locale) async {
    if (_locale.languageCode == locale.languageCode) return;
    
    _locale = locale;
    await AppLocalizations.setLocale(locale);
    notifyListeners();
  }
  
  // Toggle between Arabic and English
  Future<void> toggleLocale() async {
    final newLocale = _locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    await setLocale(newLocale);
  }
}