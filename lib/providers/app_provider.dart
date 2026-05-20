import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_currency.dart';

class AppProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _languageCode = 'id'; // Default Indonesian as requested
  AppCurrency _currency = AppCurrency.idr;
  List<String> _calcHistory = [];

  ThemeMode get themeMode => _themeMode;
  String get languageCode => _languageCode;
  AppCurrency get currency => _currency;
  String get currencyCode => _currency.code;
  List<String> get calcHistory => _calcHistory;

  AppProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    // Theme
    final themeStr = prefs.getString('theme_mode') ?? 'system';
    if (themeStr == 'light') {
      _themeMode = ThemeMode.light;
    } else if (themeStr == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }

    // Language
    _languageCode = prefs.getString('language_code') ?? 'id';

    // Currency
    _currency = AppCurrency.fromCode(prefs.getString('currency_code') ?? 'IDR');

    // Calculator History
    _calcHistory = prefs.getStringList('calc_history') ?? [];

    notifyListeners();
  }

  Future<void> changeTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    String themeStr = 'system';
    if (mode == ThemeMode.light) {
      themeStr = 'light';
    } else if (mode == ThemeMode.dark) {
      themeStr = 'dark';
    }
    await prefs.setString('theme_mode', themeStr);
  }

  Future<void> changeLanguage(String lang) async {
    _languageCode = lang;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', lang);
  }

  Future<void> changeCurrency(AppCurrency currency) async {
    if (_currency == currency) return;
    _currency = currency;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency_code', currency.code);
  }

  /// Format monetary value using the active currency.
  String formatMoney(double amount) => _currency.format(amount);

  /// Convert amount between currencies (offline rate).
  double convertMoney(double amount, AppCurrency from, AppCurrency to) {
    return to.convertFrom(amount, from);
  }

  Future<void> addCalcHistory(String expression, String result) async {
    final entry = "$expression = $result";
    // Avoid double entries
    if (_calcHistory.contains(entry)) {
      _calcHistory.remove(entry);
    }
    _calcHistory.insert(0, entry);
    // Limit to last 50 entries
    if (_calcHistory.length > 50) {
      _calcHistory = _calcHistory.sublist(0, 50);
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('calc_history', _calcHistory);
  }

  Future<void> clearCalcHistory() async {
    _calcHistory.clear();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('calc_history');
  }

  // Translation helpers
  String translate(String indonesian, String english) {
    return _languageCode == 'id' ? indonesian : english;
  }
}
