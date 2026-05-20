import 'package:intl/intl.dart';

/// Supported currencies for calculator utilities.
enum AppCurrency {
  idr,
  usd;

  String get code => this == AppCurrency.idr ? 'IDR' : 'USD';

  static AppCurrency fromCode(String code) {
    return code.toUpperCase() == 'USD' ? AppCurrency.usd : AppCurrency.idr;
  }

  String label(String lang) {
    if (lang == 'id') {
      return this == AppCurrency.idr ? 'Rupiah' : 'Dolar AS';
    }
    return this == AppCurrency.idr ? 'Rupiah' : 'US Dollar';
  }

  String get symbol => this == AppCurrency.idr ? 'Rp' : '\$';

  /// Offline reference rate: 1 USD = [exchangeRate] IDR.
  static const double exchangeRate = 16000;

  String format(double amount) {
    if (this == AppCurrency.idr) {
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(amount);
    }
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 2,
    ).format(amount);
  }

  /// Convert [amount] from [from] to this currency.
  double convertFrom(double amount, AppCurrency from) {
    if (from == this) return amount;
    if (from == AppCurrency.idr && this == AppCurrency.usd) {
      return amount / exchangeRate;
    }
    return amount * exchangeRate;
  }

  /// Default sample amounts when resetting or first open.
  double defaultAmount(String key) {
    const idrDefaults = <String, double>{
      'discount_price': 100000,
      'tip_bill': 200000,
      'loan_principal': 100000000,
      'compound_principal': 10000000,
      'fuel_price_per_l': 10000,
    };
    const usdDefaults = <String, double>{
      'discount_price': 50,
      'tip_bill': 45,
      'loan_principal': 250000,
      'compound_principal': 10000,
      'fuel_price_per_l': 1.2,
    };
    final map = this == AppCurrency.idr ? idrDefaults : usdDefaults;
    return map[key] ?? (this == AppCurrency.idr ? 100000 : 100);
  }

  String amountLabel(String lang, String baseLabelId, String baseLabelEn) {
    final name = label(lang);
    final base = lang == 'id' ? baseLabelId : baseLabelEn;
    return '$base ($name)';
  }
}
