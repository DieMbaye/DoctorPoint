import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  Locale _locale = const Locale('fr');

  Locale get locale => _locale;

  LanguageService() {
    _loadLanguage();
  }

  get language => null;

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('lang') ?? 'fr';
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', code);
    _locale = Locale(code);
    notifyListeners();
  }
}
